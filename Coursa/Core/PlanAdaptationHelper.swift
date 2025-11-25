//
//  PlanAdaptationHelper.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/11/25.
//
//  Summary
//  -------
//  Encapsulates logic for calculating weekly performance metrics based on TRIMP
//  and determining appropriate plan adjustments.
//
//  Responsibilities
//  ----------------
//  - Calculate weekly TRIMP values from completed runs
//  - Determine performance trend (undertrained/good/overreached/maintain)
//  - Estimate distances from training minutes
//  - Provide data needed for ReviewPlanSheet UI
//

import Foundation

enum PlanAdaptationHelper {
    
    // MARK: - Data Models
    
    /// Performance trend based on TRIMP analysis
    enum PerformanceTrend {
        case undertrained    // TRIMP < 90% of last week
        case goodProgress    // TRIMP within 100-110% of last week
        case overreached     // TRIMP > 120% of last week
        case maintain        // Everything else or first week
        
        var displayText: String {
            switch self {
            case .undertrained:
                return "You're slightly undertrained this week"
            case .goodProgress:
                return "Great progress! You're hitting your targets"
            case .overreached:
                return "You might be overreaching"
            case .maintain:
                return "Stay consistent with your current volume"
            }
        }
        
        var arrowDirection: ArrowDirection {
            switch self {
            case .undertrained:
                return .down
            case .goodProgress:
                return .up
            case .overreached:
                return .down
            case .maintain:
                return .same
            }
        }
    }
    
    enum ArrowDirection {
        case up, down, same
    }
    
    /// Comprehensive weekly performance metrics
    struct WeeklyPerformance {
        let thisWeekTRIMP: Double
        let lastWeekTRIMP: Double
        let thisWeekMinutes: Int
        let lastWeekMinutes: Int
        let recommendedNextWeekMinutes: Int
        let trend: PerformanceTrend
        
        // Estimated distances for UI display
        var thisWeekDistanceKm: Double {
            estimateDistanceFromMinutes(thisWeekMinutes)
        }
        
        var recommendedDistanceKm: Double {
            estimateDistanceFromMinutes(recommendedNextWeekMinutes)
        }
    }
    
    // MARK: - Performance Calculation
    
    /// Calculate comprehensive performance metrics for a given week
    /// - Parameters:
    ///   - referenceDate: Date within the week to analyze (typically today)
    ///   - plan: The current generated plan
    ///   - onboarding: User onboarding data for HR/gender calculations
    /// - Returns: WeeklyPerformance with all calculated metrics
    static func calculatePerformanceMetrics(
        for referenceDate: Date = Date(),
        plan: GeneratedPlan,
        onboarding: OnboardingData?
    ) -> WeeklyPerformance {
        let cal = Calendar.current
        
        // Get this week's runs (current week)
        let thisWeekStart = referenceDate.mondayFloor()
        let thisWeekRuns = runs(in: plan, weekStart: thisWeekStart)
            .filter { $0.status == .completed }
        
        // Get last week's runs
        let lastWeekStart = thisWeekStart.addingWeeks(-1)
        let lastWeekRuns = runs(in: plan, weekStart: lastWeekStart)
            .filter { $0.status == .completed }
        
        // Get user metrics
        let ob = onboarding ?? OnboardingStore.load()
        let age = ob?.personalInfo.age ?? 0
        let maxHR: Double = age > 0 ? Double(220 - age) : 200
        let gender: TRIMPGender = {
            let g = (ob?.personalInfo.gender ?? "").lowercased()
            return g.hasPrefix("fem") ? .female : .male
        }()
        
        // Calculate TRIMP values
        let thisWeekTRIMP = TRIMP.totalTRIMP(
            for: thisWeekRuns,
            maxHR: maxHR,
            gender: gender
        )
        
        let lastWeekTRIMP: Double
        let lastWeekMinutes: Int
        
        if !lastWeekRuns.isEmpty {
            lastWeekTRIMP = TRIMP.totalTRIMP(
                for: lastWeekRuns,
                maxHR: maxHR,
                gender: gender
            )
            lastWeekMinutes = WeeklyPlanner.estimatedWeeklyMinutes(from: lastWeekRuns)
        } else {
            // First week: use this week as baseline
            lastWeekTRIMP = thisWeekTRIMP
            lastWeekMinutes = WeeklyPlanner.estimatedWeeklyMinutes(from: thisWeekRuns)
        }
        
        let thisWeekMinutes = WeeklyPlanner.estimatedWeeklyMinutes(from: thisWeekRuns)
        
        // Determine trend
        let trend = determineTrend(
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekTRIMP: lastWeekTRIMP,
            hasLastWeek: !lastWeekRuns.isEmpty
        )
        
        // Calculate recommended next week using adaptation engine
        let recommendedMinutes = AdaptationEngine.nextWeekMinutes(
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes,
            runningFrequency: ob?.trainingPrefs.daysPerWeek ?? 3
        )
        
        return WeeklyPerformance(
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekMinutes: thisWeekMinutes,
            lastWeekMinutes: lastWeekMinutes,
            recommendedNextWeekMinutes: recommendedMinutes,
            trend: trend
        )
    }
    
    // MARK: - Private Helpers
    
    /// Determine performance trend based on TRIMP comparison
    private static func determineTrend(
        thisWeekTRIMP: Double,
        lastWeekTRIMP: Double,
        hasLastWeek: Bool
    ) -> PerformanceTrend {
        guard hasLastWeek && lastWeekTRIMP > 0 else {
            return .maintain
        }
        
        let ratio = thisWeekTRIMP / lastWeekTRIMP
        
        // Categorize based on TRIMP ratio (matching AdaptationEngine logic)
        if ratio < 0.9 {
            // Under 90% of last week -> undertrained
            return .undertrained
        } else if ratio >= 1.0 && ratio <= 1.1 {
            // 100-110% of last week -> good progress
            return .goodProgress
        } else if ratio > 1.2 {
            // Over 120% of last week -> overreached
            return .overreached
        } else {
            // Between 90-100% or 110-120% -> maintain
            return .maintain
        }
    }
    
    /// Estimate distance in kilometers from training minutes
    /// Uses a conservative 6:00/km average pace
    static func estimateDistanceFromMinutes(_ minutes: Int) -> Double {
        let avgPaceMinPerKm = 6.0  // Conservative pace
        return Double(minutes) / avgPaceMinPerKm
    }
    
    /// Get runs within a specific week
    private static func runs(in plan: GeneratedPlan, weekStart: Date) -> [ScheduledRun] {
        let weekEnd = weekStart.addingDays(7)
        return plan.runs.filter { $0.date >= weekStart && $0.date < weekEnd }
    }
}

// MARK: - Date Extensions

private extension Date {
    func mondayFloor() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // Monday
        let weekday = cal.component(.weekday, from: self)
        let delta = (weekday == 1) ? -6 : (2 - weekday)
        let start = cal.date(byAdding: .day, value: delta, to: self)!
        return cal.startOfDay(for: start)
    }
    
    func addingDays(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: n, to: self)!
    }
    
    func addingWeeks(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: 7*n, to: self)!
    }
}
