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
