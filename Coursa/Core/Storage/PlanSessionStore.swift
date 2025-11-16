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

    func applyWatchSummary(_ summary: RunningSummary) {
        // Load the current plan from in-memory or persisted storage
        guard var plan = generatedPlan ?? UserDefaultsPlanStore.shared.load()
        else {
            print(
                "[PlanSessionStore] No plan available when applying watch summary"
            )
            return
        }

        // Find the ScheduledRun matching this summary
        guard let index = plan.runs.firstIndex(where: { $0.id == summary.id })
        else {
            print(
                "[PlanSessionStore] Could not find ScheduledRun with id \(summary.id)"
            )
            return
        }

        // Update the run's actual metrics and status
        var run = plan.runs[index]
        run.status = .completed
        run.actual.elapsedSec = Int(summary.totalTime)
        run.actual.distanceKm = summary.totalDistance
        run.actual.avgHR = Int(summary.averageHeartRate)
        run.actual.avgPaceSecPerKm = Int(summary.averagePace)
        plan.runs[index] = run

        // Persist and publish back to the app
        UserDefaultsPlanStore.shared.save(plan)
        self.generatedPlan = plan
    }
}
