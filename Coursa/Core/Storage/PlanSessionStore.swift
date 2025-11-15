//
//  PlanSessionStore.swift
//  Coursa
//
//  Created by Gabriel Tanod on 15/11/25.
//

import Foundation
import SwiftUI
import Combine

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
        generatedPlan?.runs ?? []   // adjust to your real property name
    }

    /// Mutating helper: mark a run as completed/skipped here
    func updateRun(_ run: ScheduledRun) {
        guard var plan = generatedPlan else { return }

        // however you store runs in GeneratedPlan:
        if let idx = plan.runs.firstIndex(where: { $0.id == run.id }) {
            plan.runs[idx] = run
            generatedPlan = plan // triggers save + publishes change
        }
    }
}
