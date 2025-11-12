//
//  ManagePlanViewModel.swift
//  Coursa
//
//  Created by Gabriel Tanod on 11/11/25.
//

// ManagePlanViewModel.swift

import Foundation
import Combine

final class ManagePlanViewModel: ObservableObject {
    @Published private(set) var original: GeneratedPlan
    @Published var plan: Plan
    @Published var selectedDays: Set<Int>

    private let store: PlanStore

    init(store: PlanStore) {
        self.store = store
        guard let loaded = store.load() else {
            fatalError("ManagePlanViewModel: No GeneratedPlan found")
        }
        self.original = loaded
        self.plan = loaded.plan
        self.selectedDays = Self.inferSelectedDays(from: loaded)
    }

    var hasChanges: Bool {
        plan != original.plan ||
        selectedDays != Self.inferSelectedDays(from: original)
    }

    func saveChanges() {
        guard hasChanges else { return }

        let updated = PlanMapper.regeneratePlan(
            existing: original,
            newPlan: plan,
            newSelectedDays: selectedDays
        )

        store.save(updated)
        original = updated
    }

    private static func inferSelectedDays(from generated: GeneratedPlan) -> Set<Int> {
        let cal = Calendar.current
        let sample = generated.runs.prefix(14)
        return Set(sample.map { cal.component(.weekday, from: $0.date) })
    }
}
