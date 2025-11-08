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
        guard let data = OnboardingStore.load() else {
            runs = []
            return
        }

        let planVM = PlanViewModel(data: data)

        if planVM.recommendedPlan == nil {
            planVM.computeRecommendation()
        }
        if planVM.generatedPlan == nil {
            planVM.generatePlan()
        }

        if let generated = planVM.generatedPlan {
            self.runs = generated.runs.sorted { $0.date < $1.date }
        } else {
            self.runs = []
        }
        
        if let first = runs.first {
            if runs.contains(where: { calendar.isDateInToday($0.date)}) {
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
