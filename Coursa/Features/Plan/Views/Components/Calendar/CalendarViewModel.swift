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
    @Published var selectedDate: Date
    @Published var currentMonth: Date
    
    let calendar = Calendar.current
    
    init() {
        let today = calendar.startOfDay(for: Date())
        self.selectedDate = today
        self.currentMonth = Self.monthStart(for: today, calendar: calendar)
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
