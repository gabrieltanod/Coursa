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
    @Published var generatedPlan: GeneratedPlan? {
        didSet {
            if let plan = generatedPlan {
                persistence.save(plan)
            }
        }
    }

    private let persistence: PlanStore

    init(persistence: PlanStore = UserDefaultsPlanStore.shared) {
        self.persistence = persistence
        self.generatedPlan = persistence.load()
        if let plan = generatedPlan {
            print("[PlanSessionStore] init: loaded plan with \(plan.runs.count) runs")
        } else {
            print("[PlanSessionStore] init: no plan loaded")
        }
    }

    /// Helper: expose all scheduled runs if you want
    var allRuns: [ScheduledRun] {
        generatedPlan?.runs ?? []  // adjust to your real property name
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
        guard var plan = generatedPlan ?? persistence.load() else {
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

        plan.runs[index] = run

        // Persist and publish so all views update
        persistence.save(plan)
        generatedPlan = plan
        print("[PlanSessionStore] ✅ Applied summary to run \(summary.id)")
    }
}
