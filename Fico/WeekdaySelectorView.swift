//
//  WeekdaySelectorView.swift
//  Fico
//
//  Created by Gabriel Tanod on 13/10/25.
//

import SwiftUI

// MARK: - WeekdaySelectorView

struct WeekdaySelectorView: View {
    let days: [DayItem]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                VStack(spacing: 4) {
                    Text(day.weekdayShort)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text("\(day.day)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(day.isSelected ? .white : .primary)
                        .frame(width: 28, height: 28)
                        .background(day.isSelected ? Color.gray : Color.clear)
                        .clipShape(Circle())
                }
                .frame(maxWidth: .infinity)
                .accessibilityLabel("\(day.weekdayShort), \(day.day)")
                .accessibilityHint(day.isToday ? "Today" : day.isSelected ? "Selected" : "")
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, LayoutConstants.horizontalPadding)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: LayoutConstants.cornerRadius))
        .padding(.horizontal, LayoutConstants.horizontalPadding)
    }
}

// MARK: - Preview

#Preview {
    WeekdaySelectorView(days: [
        DayItem(weekdayShort: "MON", day: 1, isToday: true, isSelected: true),
        DayItem(weekdayShort: "TUE", day: 2, isToday: false, isSelected: false),
        DayItem(weekdayShort: "WED", day: 3, isToday: false, isSelected: false),
        DayItem(weekdayShort: "THU", day: 4, isToday: false, isSelected: false),
        DayItem(weekdayShort: "FRI", day: 5, isToday: false, isSelected: false),
        DayItem(weekdayShort: "SAT", day: 6, isToday: false, isSelected: false),
        DayItem(weekdayShort: "SUN", day: 7, isToday: false, isSelected: false)
    ])
    .padding()
}
