//
//  CalendarViewModel.swift
//  Coursa
//
//  Created by Gabriel Tanod on 08/11/25.
//

import Foundation
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published var runs: [ScheduledRun] = []
    @Published var selectedDate: Date
    @Published var currentMonth: Date
    
    let calendar = Calendar.current
    
    init() {
        let today = calendar.startOfDay(for: Date())
        self.selectedDate = today
        self.currentMonth = Self.monthStart(for: today, calendar: calendar)
        load()
    }
    
    //    func load() {
    //        guard let data = OnboardingStore.load() else {
    //            runs = []
    //            return
    //        }
    //
    //        let planVM = PlanViewModel(data: data)
    //        if planVM.recommendedPlan == nil {
    //            planVM.computeRecommendation()
    //        }
    //        if planVM.generatedPlan == nil {
    //            planVM.generatePlan()
    //        }
    //
    //        if let generated = planVM.generatedPlan {
    //            runs = generated.runs.sorted { $0.date < $1.date }
    //        } else {
    //            runs = []
    //        }
    //
    //        // Initial selection:
    //        if let first = runs.first {
    //            if runs.contains(where: { calendar.isDateInToday($0.date) }) {
    //                selectedDate = calendar.startOfDay(for: Date())
    //            } else {
    //                selectedDate = calendar.startOfDay(for: first.date)
    //            }
    //            currentMonth = Self.monthStart(for: selectedDate, calendar: calendar)
    //        }
    //    }
    
    func load() {
        // Load the same persisted plan used by PlanSessionStore / the rest of the app
        let storedPlan = UserDefaultsPlanStore.shared.load()
        
        if let generated = storedPlan {
            runs = generated.runs.sorted { $0.date < $1.date }
        } else {
            runs = []
        }
        
        // Initial selection:
        if let first = runs.first {
            if runs.contains(where: { calendar.isDateInToday($0.date) }) {
                selectedDate = calendar.startOfDay(for: Date())
            } else {
                selectedDate = calendar.startOfDay(for: first.date)
            }
            currentMonth = Self.monthStart(for: selectedDate, calendar: calendar)
        }
    }
    
    // MARK: - Month helpers
    
    static func monthStart(for date: Date, calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }
    
    func monthTitle() -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "LLLL, yyyy"
        return f.string(from: currentMonth)
    }
    
    func changeMonth(by value: Int) {
        guard let new = calendar.date(byAdding: .month, value: value, to: currentMonth) else { return }
        currentMonth = new
        
        // If selectedDate is not in this month, move selection to nearest run in this month
        if !calendar.isDate(selectedDate, equalTo: new, toGranularity: .month) {
            if let firstInMonth = runs.first(where: { calendar.isDate($0.date, equalTo: new, toGranularity: .month) }) {
                selectedDate = calendar.startOfDay(for: firstInMonth.date)
            }
        }
    }
    
    // MARK: - Runs
    
    func sessions(on date: Date) -> [ScheduledRun] {
        runs.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func hasRun(on date: Date) -> Bool {
        runs.contains { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    // MARK: - Grid data
    
    /// Dates for the visible month grid (Mon–Sun), `nil` = empty cell
    var monthGrid: [Date?] {
        let startOfMonth = Self.monthStart(for: currentMonth, calendar: calendar)
        guard let range = calendar.range(of: .day, in: .month, for: startOfMonth)
        else { return [] }
        
        let daysInMonth = range.count
        
        // Apple weekday: 1=Sun ... 7=Sat
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        // Convert so that Monday=0 ... Sunday=6
        let mondayBasedIndex = (firstWeekday + 5) % 7
        let leadingEmpty = mondayBasedIndex
        
        var result: [Date?] = Array(repeating: nil, count: leadingEmpty)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                result.append(date)
            }
        }
        
        // pad to full weeks
        while result.count % 7 != 0 {
            result.append(nil)
        }
        
        return result
    }
}
