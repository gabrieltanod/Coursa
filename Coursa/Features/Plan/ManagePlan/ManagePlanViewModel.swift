//
//  ManagePlanViewModel.swift
//  Coursa
//
//  Created by Gabriel Tanod on 11/11/25.
//
//  Summary
//  -------
//  Glue between persistence, PlanMapper, and the Manage Plan UI.
//  Handles "schedule day" changes while preserving history.
//
//  Responsibilities
//  ----------------
//  - Load/save plan via PlanStore (UserDefaults for v1).
//  - Track user edits (goal, days).
//  - On save: regenerate future sessions only (preserve past).
//  - Never mutates completed/skipped sessions.
//

import Combine
import Foundation

final class ManagePlanViewModel: ObservableObject {
    @Published private(set) var original: GeneratedPlan
    @Published var plan: Plan
    @Published var selectedDays: Set<Int>
    
    private let store: PlanStore
    private weak var planSession: PlanSessionStore?

    init(store: PlanStore, planSession: PlanSessionStore? = nil) {
        self.store = store
        self.planSession = planSession
        guard let loaded = store.load() else {
            fatalError("ManagePlanViewModel: No GeneratedPlan found")
        }
        self.original = loaded
        self.plan = loaded.plan
        self.selectedDays = Self.inferSelectedDays(from: loaded)
    }

    var hasChanges: Bool {
        plan != original.plan
            || selectedDays != Self.inferSelectedDays(from: original)
    }

    func saveChanges() {
        guard hasChanges, let original = store.load() else { return }

        #if DEBUG
            print("===== ENGINE DEBUG: Before schedule change =====")
            original.debugPrint(label: "Original (before Manage Plan)")
        #endif

        let updated = PlanMapper.regeneratePlan(
            existing: original,
            newPlan: original.plan,
            newSelectedDays: selectedDays
        )

        store.save(updated)
        
        // Notify PlanSessionStore to reload so HomeView updates
        planSession?.reloadFromStore()

        #if DEBUG
            print("===== ENGINE DEBUG: After schedule change =====")
            updated.debugPrint(label: "Updated (after Manage Plan)")
        #endif
    }

    private static func inferSelectedDays(from generated: GeneratedPlan) -> Set<
        Int
    > {
        let cal = Calendar.current
        let sample = generated.runs.prefix(14)
        return Set(sample.map { cal.component(.weekday, from: $0.date) })
    }
}
