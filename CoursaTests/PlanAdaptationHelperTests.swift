//
//  PlanAdaptationHelperTests.swift
//  CoursaTests
//
//  Created by Gabriel Tanod on 24/11/25.
//
//  Comprehensive tests for PlanAdaptationHelper using Swift Testing.
//

import Foundation
import Testing

@testable import Coursa

struct PlanAdaptationHelperTests {
    
    // MARK: - Test Helpers
    
    private func makeDate(_ str: String) -> Date {
        let parts = str.split(separator: "-")
        let y = Int(parts[0])!, m = Int(parts[1])!, d = Int(parts[2])!
        var comps = DateComponents()
        comps.year = y; comps.month = m; comps.day = d
        let cal = Calendar.current
        let dt = cal.date(from: comps)!
        return cal.startOfDay(for: dt)
    }
    
    private func makeRun(
        date: Date,
        durationMin: Int,
        avgHR: Int?,
        completed: Bool = true
    ) -> ScheduledRun {
        let template = RunTemplate(
            name: "Test Run",
            kind: .easy,
            focus: .base,
            targetDurationSec: durationMin * 60,
            targetDistanceKm: nil,
            targetHRZone: .z2,
            notes: nil
        )
        
        var run = ScheduledRun(date: date, template: template)
        if completed {
            run.status = .completed
            run.actual.elapsedSec = durationMin * 60
            run.actual.avgHR = avgHR
        }
        return run
    }
    
    private func makePlan(runs: [ScheduledRun]) -> GeneratedPlan {
        GeneratedPlan(plan: .endurance, runs: runs.sorted { $0.date < $1.date })
    }
    
    private func makeOnboarding(age: Int, gender: String, daysPerWeek: Int = 3) -> OnboardingData {
        var data = OnboardingData()
        data.personalInfo.age = age
        data.personalInfo.gender = gender
        data.trainingPrefs.daysPerWeek = daysPerWeek
        return data
    }
    
    // MARK: - Performance Trend Tests
    
    @Test
    func determineTrend_returnsUndertrained_whenTRIMPBelowNinetyPercent() {
        // Given: This week TRIMP is 80% of last week
        let thisWeekStart = makeDate("2025-01-13") // Monday
        let lastWeekStart = makeDate("2025-01-06")
        
        // Last week: 3 runs × 50min = 150min
        let lastWeekRuns = [
            makeRun(date: lastWeekStart, durationMin: 50, avgHR: 140),
            makeRun(date: lastWeekStart.addingTimeInterval(2*24*3600), durationMin: 50, avgHR: 140),
            makeRun(date: lastWeekStart.addingTimeInterval(4*24*3600), durationMin: 50, avgHR: 140)
        ]
        
        // This week: 3 runs × 40min = 120min (80% of last week)
        let thisWeekRuns = [
            makeRun(date: thisWeekStart, durationMin: 40, avgHR: 135),
            makeRun(date: thisWeekStart.addingTimeInterval(2*24*3600), durationMin: 40, avgHR: 135),
            makeRun(date: thisWeekStart.addingTimeInterval(4*24*3600), durationMin: 40, avgHR: 135)
        ]
        
        let plan = makePlan(runs: lastWeekRuns + thisWeekRuns)
        let onboarding = makeOnboarding(age: 30, gender: "Male")
        
        // When
        let performance = PlanAdaptationHelper.calculatePerformanceMetrics(
            for: thisWeekStart.addingTimeInterval(5*24*3600), // Friday in this week
            plan: plan,
            onboarding: onboarding
        )
        
        // Then
        #expect(performance.trend == .undertrained)
        #expect(performance.thisWeekMinutes == 120)
        #expect(performance.lastWeekMinutes == 150)
    }
    
    @Test
    func determineTrend_returnsGoodProgress_whenTRIMPWithinTargetRange() {
        // Given: This week TRIMP is 105% of last week (within 100-110%)
        let thisWeekStart = makeDate("2025-01-13")
        let lastWeekStart = makeDate("2025-01-06")
        
        let lastWeekRuns = [
            makeRun(date: lastWeekStart, durationMin: 50, avgHR: 140),
            makeRun(date: lastWeekStart.addingTimeInterval(2*24*3600), durationMin: 50, avgHR: 140),
            makeRun(date: lastWeekStart.addingTimeInterval(4*24*3600), durationMin: 50, avgHR: 140)
        ]
        
        // Slightly more this week: 3 runs × 53min = 159min with similar HR
        let thisWeekRuns = [
            makeRun(date: thisWeekStart, durationMin: 53, avgHR: 140),
            makeRun(date: thisWeekStart.addingTimeInterval(2*24*3600), durationMin: 53, avgHR: 140),
            makeRun(date: thisWeekStart.addingTimeInterval(4*24*3600), durationMin: 53, avgHR: 140)
        ]
        
        let plan = makePlan(runs: lastWeekRuns + thisWeekRuns)
        let onboarding = makeOnboarding(age: 30, gender: "Male")
        
        // When
        let performance = PlanAdaptationHelper.calculatePerformanceMetrics(
            for: thisWeekStart.addingTimeInterval(5*24*3600),
            plan: plan,
            onboarding: onboarding
        )
        
        // Then
        #expect(performance.trend == .goodProgress)
        #expect(performance.thisWeekMinutes > performance.lastWeekMinutes)
        #expect(performance.recommendedNextWeekMinutes > performance.thisWeekMinutes)
    }
    
    @Test
    func determineTrend_returnsOverreached_whenTRIMPAboveOneTwentyPercent() {
        // Given: This week TRIMP is 130% of last week (way too much)
        let thisWeekStart = makeDate("2025-01-13")
        let lastWeekStart = makeDate("2025-01-06")
        
        let lastWeekRuns = [
            makeRun(date: lastWeekStart, durationMin: 40, avgHR: 135),
            makeRun(date: lastWeekStart.addingTimeInterval(2*24*3600), durationMin: 40, avgHR: 135),
            makeRun(date: lastWeekStart.addingTimeInterval(4*24*3600), durationMin: 40, avgHR: 135)
        ]
        
        // Much more this week with higher intensity
        let thisWeekRuns = [
            makeRun(date: thisWeekStart, durationMin: 60, avgHR: 155),
            makeRun(date: thisWeekStart.addingTimeInterval(2*24*3600), durationMin: 60, avgHR: 155),
            makeRun(date: thisWeekStart.addingTimeInterval(4*24*3600), durationMin: 60, avgHR: 155)
        ]
        
        let plan = makePlan(runs: lastWeekRuns + thisWeekRuns)
        let onboarding = makeOnboarding(age: 30, gender: "Male")
        
        // When
        let performance = PlanAdaptationHelper.calculatePerformanceMetrics(
            for: thisWeekStart.addingTimeInterval(5*24*3600),
            plan: plan,
            onboarding: onboarding
        )
        
        // Then
        #expect(performance.trend == .overreached)
        #expect(performance.thisWeekMinutes > performance.lastWeekMinutes)
        // Should recommend repeating or reducing
        #expect(performance.recommendedNextWeekMinutes <= performance.lastWeekMinutes * 110 / 100)
    }
    
    @Test
    func determineTrend_returnsMaintain_whenFirstWeek() {
        // Given: Only this week's data, no previous week
        let thisWeekStart = makeDate("2025-01-13")
        
        let thisWeekRuns = [
            makeRun(date: thisWeekStart, durationMin: 50, avgHR: 140),
            makeRun(date: thisWeekStart.addingTimeInterval(2*24*3600), durationMin: 50, avgHR: 140),
            makeRun(date: thisWeekStart.addingTimeInterval(4*24*3600), durationMin: 50, avgHR: 140)
        ]
        
        let plan = makePlan(runs: thisWeekRuns)
        let onboarding = makeOnboarding(age: 30, gender: "Male")
        
        // When
        let performance = PlanAdaptationHelper.calculatePerformanceMetrics(
            for: thisWeekStart.addingTimeInterval(5*24*3600),
            plan: plan,
            onboarding: onboarding
        )
        
        // Then: First week should maintain
        #expect(performance.trend == .maintain)
        #expect(performance.thisWeekMinutes == 150)
        #expect(performance.lastWeekMinutes == 150) // Uses this week as baseline
    }
    
    // MARK: - Distance Estimation Tests
    
    @Test
    func estimateDistanceFromMinutes_usesConservativePace() {
        // Given: Conservative 6:00/km pace
        let minutes150 = 150
        let minutes180 = 180
        
        // When
        let distance150 = PlanAdaptationHelper.estimateDistanceFromMinutes(minutes150)
        let distance180 = PlanAdaptationHelper.estimateDistanceFromMinutes(minutes180)
        
        // Then: 150min / 6min/km = 25km, 180min / 6min/km = 30km
        #expect(distance150 == 25.0)
        #expect(distance180 == 30.0)
    }
    
    @Test
    func weeklyPerformance_calculatesDistancesCorrectly() {
        // Given a performance with specific minutes
        let thisWeekStart = makeDate("2025-01-13")
        let lastWeekStart = makeDate("2025-01-06")
        
        let lastWeekRuns = [
            makeRun(date: lastWeekStart, durationMin: 60, avgHR: 140),
            makeRun(date: lastWeekStart.addingTimeInterval(2*24*3600), durationMin: 60, avgHR: 140),
            makeRun(date: lastWeekStart.addingTimeInterval(4*24*3600), durationMin: 60, avgHR: 140)
        ]
        
        let thisWeekRuns = [
            makeRun(date: thisWeekStart, durationMin: 60, avgHR: 140),
            makeRun(date: thisWeekStart.addingTimeInterval(2*24*3600), durationMin: 60, avgHR: 140),
            makeRun(date: thisWeekStart.addingTimeInterval(4*24*3600), durationMin: 60, avgHR: 140)
        ]
        
        let plan = makePlan(runs: lastWeekRuns + thisWeekRuns)
        let onboarding = makeOnboarding(age: 30, gender: "Male")
        
        // When
        let performance = PlanAdaptationHelper.calculatePerformanceMetrics(
            for: thisWeekStart.addingTimeInterval(5*24*3600),
            plan: plan,
            onboarding: onboarding
        )
        
        // Then: 180 min / 6 min/km = 30km
        #expect(performance.thisWeekDistanceKm == 30.0)
        #expect(performance.recommendedDistanceKm > 0)
    }
    
    // MARK: - TRIMP Calculation Tests
    
    @Test
    func calculatePerformanceMetrics_usesActualHeartRateData() {
        // Given runs with different heart rates
        let thisWeekStart = makeDate("2025-01-13")
        let lastWeekStart = makeDate("2025-01-06")
        
        // Last week: lower intensity (HR 130)
        let lastWeekRuns = [
            makeRun(date: lastWeekStart, durationMin: 50, avgHR: 130),
            makeRun(date: lastWeekStart.addingTimeInterval(2*24*3600), durationMin: 50, avgHR: 130),
            makeRun(date: lastWeekStart.addingTimeInterval(4*24*3600), durationMin: 50, avgHR: 130)
        ]
        
        // This week: higher intensity (HR 150) but same duration
        let thisWeekRuns = [
            makeRun(date: thisWeekStart, durationMin: 50, avgHR: 150),
            makeRun(date: thisWeekStart.addingTimeInterval(2*24*3600), durationMin: 50, avgHR: 150),
            makeRun(date: thisWeekStart.addingTimeInterval(4*24*3600), durationMin: 50, avgHR: 150)
        ]
        
        let plan = makePlan(runs: lastWeekRuns + thisWeekRuns)
        let onboarding = makeOnboarding(age: 30, gender: "Male")
        
        // When
        let performance = PlanAdaptationHelper.calculatePerformanceMetrics(
            for: thisWeekStart.addingTimeInterval(5*24*3600),
            plan: plan,
            onboarding: onboarding
        )
        
        // Then: Same minutes but higher HR should give higher TRIMP
        #expect(performance.thisWeekMinutes == performance.lastWeekMinutes)
        #expect(performance.thisWeekTRIMP > performance.lastWeekTRIMP)
    }
    
    @Test
    func calculatePerformanceMetrics_respectsUserAgeAndGender() {
        // Given: Female user age 25
        let thisWeekStart = makeDate("2025-01-13")
        
        let thisWeekRuns = [
            makeRun(date: thisWeekStart, durationMin: 50, avgHR: 140),
            makeRun(date: thisWeekStart.addingTimeInterval(2*24*3600), durationMin: 50, avgHR: 140),
            makeRun(date: thisWeekStart.addingTimeInterval(4*24*3600), durationMin: 50, avgHR: 140)
        ]
        
        let plan = makePlan(runs: thisWeekRuns)
        let onboarding = makeOnboarding(age: 25, gender: "Female")
        
        // When
        let performance = PlanAdaptationHelper.calculatePerformanceMetrics(
            for: thisWeekStart.addingTimeInterval(5*24*3600),
            plan: plan,
            onboarding: onboarding
        )
        
        // Then: Should use female TRIMP constants and age-based maxHR (220-25=195)
        #expect(performance.thisWeekTRIMP > 0)
        #expect(performance.thisWeekMinutes == 150)
        // Female TRIMP constants (k1=0.86, k2=1.67) differ from male
    }
    
    // MARK: - Edge Cases
    
    @Test
    func calculatePerformanceMetrics_handlesNoCompletedRuns() {
        // Given: Planned runs but none completed
        let thisWeekStart = makeDate("2025-01-13")
        
        let thisWeekRuns = [
            makeRun(date: thisWeekStart, durationMin: 50, avgHR: nil, completed: false),
            makeRun(date: thisWeekStart.addingTimeInterval(2*24*3600), durationMin: 50, avgHR: nil, completed: false)
        ]
        
        let plan = makePlan(runs: thisWeekRuns)
        let onboarding = makeOnboarding(age: 30, gender: "Male")
        
        // When
        let performance = PlanAdaptationHelper.calculatePerformanceMetrics(
            for: thisWeekStart.addingTimeInterval(5*24*3600),
            plan: plan,
            onboarding: onboarding
        )
        
        // Then: Should handle gracefully with zero TRIMP
        #expect(performance.thisWeekTRIMP == 0)
        #expect(performance.thisWeekMinutes == 0)
    }
    
    @Test
    func calculatePerformanceMetrics_handlesPartialWeekData() {
        // Given: Only 1 out of 3 runs completed
        let thisWeekStart = makeDate("2025-01-13")
        let lastWeekStart = makeDate("2025-01-06")
        
        let lastWeekRuns = [
            makeRun(date: lastWeekStart, durationMin: 50, avgHR: 140),
            makeRun(date: lastWeekStart.addingTimeInterval(2*24*3600), durationMin: 50, avgHR: 140),
            makeRun(date: lastWeekStart.addingTimeInterval(4*24*3600), durationMin: 50, avgHR: 140)
        ]
        
        let thisWeekRuns = [
            makeRun(date: thisWeekStart, durationMin: 50, avgHR: 140, completed: true),
            makeRun(date: thisWeekStart.addingTimeInterval(2*24*3600), durationMin: 50, avgHR: nil, completed: false),
            makeRun(date: thisWeekStart.addingTimeInterval(4*24*3600), durationMin: 50, avgHR: nil, completed: false)
        ]
        
        let plan = makePlan(runs: lastWeekRuns + thisWeekRuns)
        let onboarding = makeOnboarding(age: 30, gender: "Male")
        
        // When
        let performance = PlanAdaptationHelper.calculatePerformanceMetrics(
            for: thisWeekStart.addingTimeInterval(5*24*3600),
            plan: plan,
            onboarding: onboarding
        )
        
        // Then: Should calculate based on completed runs only
        #expect(performance.thisWeekMinutes == 50)
        #expect(performance.lastWeekMinutes == 150)
        #expect(performance.trend == .undertrained) // Only 33% of last week
    }
    
    @Test
    func calculatePerformanceMetrics_handlesMissingOnboardingData() {
        // Given: No onboarding data
        let thisWeekStart = makeDate("2025-01-13")
        
        let thisWeekRuns = [
            makeRun(date: thisWeekStart, durationMin: 50, avgHR: 140),
            makeRun(date: thisWeekStart.addingTimeInterval(2*24*3600), durationMin: 50, avgHR: 140)
        ]
        
        let plan = makePlan(runs: thisWeekRuns)
        
        // When: Pass nil onboarding
        let performance = PlanAdaptationHelper.calculatePerformanceMetrics(
            for: thisWeekStart.addingTimeInterval(5*24*3600),
            plan: plan,
            onboarding: nil
        )
        
        // Then: Should use fallback values (maxHR=200, male)
        #expect(performance.thisWeekTRIMP > 0)
        #expect(performance.thisWeekMinutes == 100)
    }
    
    @Test
    func calculatePerformanceMetrics_handlesRunsWithoutHeartRateData() {
        // Given: Completed runs but no HR data
        let thisWeekStart = makeDate("2025-01-13")
        
        let thisWeekRuns = [
            makeRun(date: thisWeekStart, durationMin: 50, avgHR: nil, completed: true),
            makeRun(date: thisWeekStart.addingTimeInterval(2*24*3600), durationMin: 50, avgHR: nil, completed: true)
        ]
        
        let plan = makePlan(runs: thisWeekRuns)
        let onboarding = makeOnboarding(age: 30, gender: "Male")
        
        // When
        let performance = PlanAdaptationHelper.calculatePerformanceMetrics(
            for: thisWeekStart.addingTimeInterval(5*24*3600),
            plan: plan,
            onboarding: onboarding
        )
        
        // Then: Should use fallback HR (nominal Zone 2 = 0.65 intensity)
        #expect(performance.thisWeekTRIMP > 0) // Still calculates TRIMP with fallback
        #expect(performance.thisWeekMinutes == 100)
    }
    
    // MARK: - Arrow Direction Tests
    
    @Test
    func performanceTrend_arrowDirection_matchesTrend() {
        #expect(PlanAdaptationHelper.PerformanceTrend.goodProgress.arrowDirection == .up)
        #expect(PlanAdaptationHelper.PerformanceTrend.undertrained.arrowDirection == .down)
        #expect(PlanAdaptationHelper.PerformanceTrend.overreached.arrowDirection == .down)
        #expect(PlanAdaptationHelper.PerformanceTrend.maintain.arrowDirection == .same)
    }
    
    @Test
    func performanceTrend_displayText_isDescriptive() {
        let goodProgress = PlanAdaptationHelper.PerformanceTrend.goodProgress.displayText
        let undertrained = PlanAdaptationHelper.PerformanceTrend.undertrained.displayText
        let overreached = PlanAdaptationHelper.PerformanceTrend.overreached.displayText
        let maintain = PlanAdaptationHelper.PerformanceTrend.maintain.displayText
        
        #expect(goodProgress.contains("progress") || goodProgress.contains("Great"))
        #expect(undertrained.contains("undertrain") || undertrained.contains("less"))
        #expect(overreached.contains("overreach") || overreached.contains("harder"))
        #expect(maintain.contains("maintain") || maintain.contains("consistent"))
    }
}
