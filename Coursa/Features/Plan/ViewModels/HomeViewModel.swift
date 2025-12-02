//
//  HomeViewModel.swift
//  Coursa
//
//  Created by Gabriel Tanod on 08/11/25.
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var runs: [ScheduledRun] = []
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())

    private let calendar = Calendar.current

    init() {
        loadPlan()
    }

    func loadPlan() {
        // Load the same generated plan that PlanView / PlanSessionStore persist
        guard let generated = UserDefaultsPlanStore.shared.load() else {
            runs = []
            return
        }

        runs = generated.runs.sorted { $0.date < $1.date }

        // Keep selectedDate aligned to either "today" (if there is a run today),
        // or the first available run in the plan.
        if let first = runs.first {
            if runs.contains(where: { calendar.isDateInToday($0.date) }) {
                selectedDate = calendar.startOfDay(for: Date())
            } else {
                selectedDate = calendar.startOfDay(for: first.date)
            }
        }
    }

    func hasRun(on date: Date) -> Bool {
        runs.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func sessions(on date: Date) -> [ScheduledRun] {
        runs.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    var todaySessions: [ScheduledRun] {
        sessions(on: Date())
    }
}
