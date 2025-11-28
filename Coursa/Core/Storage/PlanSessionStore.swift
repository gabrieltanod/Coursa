//
//  PlanSessionStore.swift
//  Coursa
//
//  Created by Gabriel Tanod on 15/11/25.
//

import Combine
import Foundation
import SwiftUI

final class PlanSessionStore: ObservableObject {
    @Published var generatedPlan: GeneratedPlan?

    /// Convenience: all runs in the current plan
    var allRuns: [ScheduledRun] {
        generatedPlan?.runs ?? []
    }

    private let planStore: PlanStore

    init(planStore: PlanStore = UserDefaultsPlanStore.shared) {
        self.planStore = planStore

        // 👇 Load any existing plan at startup
        if let stored = planStore.load() {
            self.generatedPlan = stored
        } else {
            self.generatedPlan = nil
        }
    }

    /// Replace the current plan, save it, and notify listeners.
    func replacePlan(with newPlan: GeneratedPlan) {
        self.generatedPlan = newPlan
        planStore.save(newPlan)
    }

    /// Reload from persistence if needed.
    func reloadFromStore() {
        if let stored = planStore.load() {
            self.generatedPlan = stored
        } else {
            self.generatedPlan = nil
        }
    }

    /// 🔑 Bootstrap at app level:
    /// - If a plan exists in storage, use it.
    /// - Otherwise, generate one from onboarding data using existing logic.
    func bootstrapIfNeeded(using onboarding: OnboardingData) {
        // already have a plan? do nothing
        if generatedPlan != nil { return }

        // Prefer whatever is persisted
        if let stored = planStore.load() {
            self.generatedPlan = stored
            return
        }

        // Otherwise, generate using your existing PlanViewModel logic
        let vm = PlanViewModel(data: onboarding)
        if vm.recommendedPlan == nil {
            vm.computeRecommendation()
        }
        vm.ensurePlanUpToDate()
        vm.applyAutoSkipIfNeeded()

        // Your PlanViewModel already writes to UserDefaultsPlanStore.
        // After that, load it back into this store:
        if let newStored = planStore.load() {
            self.generatedPlan = newStored
        }
    }

    /// Mutating helper: mark a run as completed/skipped here
    func updateRun(_ run: ScheduledRun) {
        guard var plan = generatedPlan else { return }

        // however you store runs in GeneratedPlan:
        if let idx = plan.runs.firstIndex(where: { $0.id == run.id }) {
            plan.runs[idx] = run
            generatedPlan = plan  // triggers save + publishes change
        }
    }

    /// Apply a RunningSummary coming from watch to the matching ScheduledRun
    func apply(summary: RunningSummary) {
        print("[PlanSessionStore] apply(summary:) called with id=\(summary.id)")

        // Try in-memory plan, otherwise load from persistence
        guard var plan = generatedPlan ?? planStore.load() else {
            print(
                "[PlanSessionStore] No generatedPlan loaded or persisted when applying summary"
            )
            return
        }

        print("[PlanSessionStore] Loaded plan with \(plan.runs.count) runs")

        guard let index = plan.runs.firstIndex(where: { $0.id == summary.id })
        else {
            print(
                "[PlanSessionStore] No ScheduledRun found for id \(summary.id)"
            )
            return
        }

        var run = plan.runs[index]

        // Mark as completed & fill metrics
        run.status = .completed
        run.actual.elapsedSec = Int(summary.totalTime)
        run.actual.distanceKm = summary.totalDistance
        run.actual.avgHR = Int(summary.averageHeartRate)
        run.actual.avgPaceSecPerKm = Int(summary.averagePace)
        run.actual.zoneDuration = summary.zoneDuration
        
        // Update the date to reflect the actual start time
        // Assuming 'now' is roughly when the run finished
        run.date = Date().addingTimeInterval(-summary.totalTime)

        plan.runs[index] = run

        // Persist and publish so all views update
        planStore.save(plan)
        generatedPlan = plan
        print("[PlanSessionStore] ✅ Applied summary to run \(summary.id)")
    }
}


#if DEBUG
extension PlanSessionStore {
    func loadDebugSampleDataForStatistics() {
        let cal = Calendar.current
        let now = Date()

        func dayOffset(_ days: Int) -> Date {
            cal.date(byAdding: .day, value: days, to: now) ?? now
        }

        func makeRun(
            title: String,
            daysAgo: Int,
            distanceKm: Double,
            elapsedSec: Int,
            zone2Sec: Double
        ) -> ScheduledRun {
            var actual = RunMetrics.empty
            actual.distanceKm = distanceKm
            actual.elapsedSec = elapsedSec
            actual.zoneDuration = [2: zone2Sec]

            return ScheduledRun(
                id: UUID().uuidString,
                date: dayOffset(-daysAgo),
                template: RunTemplate(
                    name: title,
                    kind: .easy,
                    focus: .endurance,
                    targetDurationSec: elapsedSec,
                    targetDistanceKm: distanceKm,
                    targetHRZone: .z2,
                    notes: nil
                ),
                status: .completed,
                actual: actual
            )
        }

        // This week (0–6 days ago)
        let run1 = makeRun(
            title: "This Week Run 1",
            daysAgo: 1,
            distanceKm: 5,
            elapsedSec: 5 * 60 * 8,   // 8:00/km
            zone2Sec: 30 * 60         // 30 min
        )

        let run2 = makeRun(
            title: "This Week Run 2",
            daysAgo: 3,
            distanceKm: 3,
            elapsedSec: 3 * 60 * 7,   // 7:00/km
            zone2Sec: 20 * 60         // 20 min
        )

        // Last week (7–13 days ago)
        let run3 = makeRun(
            title: "Last Week Run 1",
            daysAgo: 8,
            distanceKm: 4,
            elapsedSec: 4 * 60 * 9,   // 9:00/km
            zone2Sec: 25 * 60
        )

        let run4 = makeRun(
            title: "Last Week Run 2",
            daysAgo: 10,
            distanceKm: 6,
            elapsedSec: 6 * 60 * 8,   // 8:00/km
            zone2Sec: 35 * 60
        )

        let plan = GeneratedPlan(
            plan: .endurance,
            runs: [run1, run2, run3, run4].sorted { $0.date < $1.date }
        )

        generatedPlan = plan
    }
    
    /// Debug data specifically for testing pace recommendations
    /// Creates runs with clear zone 2 data to demonstrate dynamic pace calculation
    func loadPaceRecommendationDebugData() {
        print("📊 [DEBUG] Loading Pace Recommendation Test Data...")
        
        let cal = Calendar.current
        let now = Date()
        
        func dayOffset(_ days: Int) -> Date {
            cal.date(byAdding: .day, value: days, to: now) ?? now
        }
        
        func makeCompletedRun(
            title: String,
            daysAgo: Int,
            distanceKm: Double,
            paceSecPerKm: Int,  // e.g., 480 = 8:00/km
            zone2Percentage: Double  // e.g., 0.80 = 80% in zone 2
        ) -> ScheduledRun {
            let elapsedSec = Int(Double(paceSecPerKm) * distanceKm)
            let zone2Sec = Double(elapsedSec) * zone2Percentage
            
            var actual = RunMetrics.empty
            actual.distanceKm = distanceKm
            actual.elapsedSec = elapsedSec
            actual.avgPaceSecPerKm = paceSecPerKm
            actual.avgHR = 140
            actual.zoneDuration = [2: zone2Sec]
            
            print("  ✅ \(title): \(distanceKm)km at \(paceSecPerKm/60):\(String(format: "%02d", paceSecPerKm%60))/km, \(Int(zone2Percentage*100))% in Z2")
            
            return ScheduledRun(
                id: UUID().uuidString,
                date: dayOffset(-daysAgo),
                template: RunTemplate(
                    name: title,
                    kind: .easy,
                    focus: .endurance,
                    targetDurationSec: elapsedSec,
                    targetDistanceKm: distanceKm,
                    targetHRZone: .z2,
                    notes: nil
                ),
                status: .completed,
                actual: actual
            )
        }
        
        func makePlannedRun(
            title: String,
            daysInFuture: Int,
            distanceKm: Double,
            targetSec: Int
        ) -> ScheduledRun {
            return ScheduledRun(
                id: UUID().uuidString,
                date: dayOffset(daysInFuture),
                template: RunTemplate(
                    name: title,
                    kind: .easy,
                    focus: .endurance,
                    targetDurationSec: targetSec,
                    targetDistanceKm: distanceKm,
                    targetHRZone: .z2,
                    notes: nil
                ),
                status: .planned,
                actual: RunMetrics.empty
            )
        }
        
        // Create 5 recent runs with GOOD zone 2 adherence (>70%)
        // Average pace will be approximately 8:00/km
        let goodRuns = [
            makeCompletedRun(title: "Morning Easy", daysAgo: 2, distanceKm: 5.0, paceSecPerKm: 480, zone2Percentage: 0.75),  // 8:00/km, 75% Z2
            makeCompletedRun(title: "Evening Run", daysAgo: 4, distanceKm: 6.0, paceSecPerKm: 450, zone2Percentage: 0.80),   // 7:30/km, 80% Z2
            makeCompletedRun(title: "Weekend Long", daysAgo: 6, distanceKm: 8.0, paceSecPerKm: 510, zone2Percentage: 0.78),  // 8:30/km, 78% Z2
            makeCompletedRun(title: "Recovery Run", daysAgo: 9, distanceKm: 4.0, paceSecPerKm: 480, zone2Percentage: 0.82),  // 8:00/km, 82% Z2
            makeCompletedRun(title: "Steady Run", daysAgo: 11, distanceKm: 6.0, paceSecPerKm: 480, zone2Percentage: 0.76),   // 8:00/km, 76% Z2
        ]
        
        // Expected recommended pace: ~8:00/km average + 10 sec buffer = 8:10/km
        
        // Create today's planned run to test the recommendation
        let todayRun = makePlannedRun(
            title: "Today's Easy Run",
            daysInFuture: 0,
            distanceKm: 5.0,
            targetSec: 2400  // 40 minutes
        )
        
        let allRuns = (goodRuns + [todayRun]).sorted { $0.date < $1.date }
        
        let plan = GeneratedPlan(
            plan: .endurance,
            runs: allRuns
        )
        
        generatedPlan = plan
        
        print("📊 [DEBUG] Loaded \(goodRuns.count) completed runs with good Z2 adherence")
        print("📊 [DEBUG] Expected recommended pace: ~8:10/km (avg 8:00/km + 10 sec buffer)")
        print("📊 [DEBUG] Navigate to 'Today's Easy Run' detail page to see the recommendation!")
    }
    
    /// Simulate completing a run with custom pace and zone 2 data
    /// Use this to test how recommended pace updates dynamically
    func simulateCompletedRun(paceSecPerKm: Int, zone2Percentage: Double) {
        guard var plan = generatedPlan else {
            print("❌ No plan available")
            return
        }
        
        // Find first planned run
        guard let index = plan.runs.firstIndex(where: { $0.status == .planned }) else {
            print("❌ No planned runs to complete")
            return
        }
        
        var run = plan.runs[index]
        let distanceKm = run.template.targetDistanceKm ?? 5.0
        let elapsedSec = Int(Double(paceSecPerKm) * distanceKm)
        let zone2Sec = Double(elapsedSec) * zone2Percentage
        
        // Mark as completed with custom data
        run.status = .completed
        run.actual.distanceKm = distanceKm
        run.actual.elapsedSec = elapsedSec
        run.actual.avgPaceSecPerKm = paceSecPerKm
        run.actual.avgHR = 140
        run.actual.zoneDuration = [2: zone2Sec]
        
        plan.runs[index] = run
        generatedPlan = plan
        
        print("✅ Simulated run completed:")
        print("   📍 Distance: \(distanceKm)km")
        print("   ⏱️ Pace: \(paceSecPerKm/60):\(String(format: "%02d", paceSecPerKm%60))/km")
        print("   💚 Zone 2: \(Int(zone2Percentage*100))%")
        print("📊 Navigate to another run's detail page to see updated recommendation!")
    }
    
    func loadScenario2Data() {
        let cal = Calendar.current
        let now = Date()
        
        // Get the start of the current week (Monday)
        let startOfThisWeek = cal.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let mondayOfThisWeek = cal.nextDate(
            after: startOfThisWeek, 
            matching: DateComponents(weekday: 2), 
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? startOfThisWeek
        
        func dayOffset(_ days: Int) -> Date {
            cal.date(byAdding: .day, value: days, to: now) ?? now
        }
        
        func weekOffset(_ weeks: Int, day: Int = 0) -> Date {
            let weekStart = cal.date(byAdding: .weekOfYear, value: weeks, to: mondayOfThisWeek) ?? mondayOfThisWeek
            return cal.date(byAdding: .day, value: day, to: weekStart) ?? weekStart
        }
        
        func makeCompletedRun(
            title: String,
            date: Date,
            distanceKm: Double,
            elapsedSec: Int,
            zone2Sec: Double
        ) -> ScheduledRun {
            var actual = RunMetrics.empty
            actual.distanceKm = distanceKm
            actual.elapsedSec = elapsedSec
            actual.zoneDuration = [2: zone2Sec]

            return ScheduledRun(
                id: UUID().uuidString,
                date: date,
                template: RunTemplate(
                    name: title,
                    kind: .easy,
                    focus: .endurance,
                    targetDurationSec: elapsedSec,
                    targetDistanceKm: distanceKm,
                    targetHRZone: .z2,
                    notes: nil
                ),
                status: .completed,
                actual: actual
            )
        }
        
        func makePlannedRun(
            title: String,
            date: Date,
            kind: RunKind = .easy,
            distanceKm: Double,
            targetSec: Int
        ) -> ScheduledRun {
            return ScheduledRun(
                id: UUID().uuidString,
                date: date,
                template: RunTemplate(
                    name: title,
                    kind: kind,
                    focus: .endurance,
                    targetDurationSec: targetSec,
                    targetDistanceKm: distanceKm,
                    targetHRZone: .z2,
                    notes: nil  // Remove custom notes to use default description
                ),
                status: .planned,
                actual: RunMetrics.empty
            )
        }
        
        // Historical runs from previous weeks
        let historyRun1 = makeCompletedRun(
            title: "Morning Easy Run",
            date: weekOffset(-1, day: 1), // Tuesday last week
            distanceKm: 5.0,
            elapsedSec: 5 * 60 * 8,   // 8:00/km
            zone2Sec: 30 * 60         // 30 min
        )
        
        let historyRun2 = makeCompletedRun(
            title: "Weekend Long Run", 
            date: weekOffset(-1, day: 5), // Saturday last week
            distanceKm: 8.0,
            elapsedSec: 8 * 60 * 9,   // 9:00/km
            zone2Sec: 50 * 60         // 50 min
        )
        
        let historyRun3 = makeCompletedRun(
            title: "Tempo Run",
            date: weekOffset(-2, day: 3), // Thursday two weeks ago
            distanceKm: 4.0,
            elapsedSec: 4 * 60 * 7,   // 7:00/km
            zone2Sec: 20 * 60         // 20 min
        )
        
        // Current week runs: Today and next 2 days
        let todayRun = makePlannedRun(
            title: "Today's Easy Run",
            date: now, // Today
            kind: .easy,
            distanceKm: 5.0,
            targetSec: 5 * 60 * 8    // 8:00/km target
        )
        
        let tomorrowRun = makePlannedRun(
            title: "Recovery Run",
            date: dayOffset(1), // Tomorrow
            kind: .easy,
            distanceKm: 3.0,
            targetSec: 3 * 60 * 9    // 9:00/km target
        )
        
        let dayAfterRun = makePlannedRun(
            title: "Interval Training",
            date: dayOffset(2), // Day after tomorrow
            kind: .intervals,
            distanceKm: 6.0,
            targetSec: 6 * 60 * 7    // 7:00/km target
        )
        
        // Add a couple more runs in the current week to make it look more realistic
        let thisWeekRun4 = makePlannedRun(
            title: "Long Run",
            date: weekOffset(0, day: 6), // Sunday this week
            kind: .long,
            distanceKm: 10.0,
            targetSec: 10 * 60 * 9   // 9:00/km target
        )
        
        let allRuns = [historyRun1, historyRun2, historyRun3, todayRun, tomorrowRun, dayAfterRun, thisWeekRun4]
            .sorted { $0.date < $1.date }
        
        let plan = GeneratedPlan(
            plan: .endurance,
            runs: allRuns
        )
        
        generatedPlan = plan
    }
}
#endif
