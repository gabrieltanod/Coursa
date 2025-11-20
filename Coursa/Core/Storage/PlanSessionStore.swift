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
}
#endif
