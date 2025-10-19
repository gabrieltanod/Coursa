//
//  Models.swift
//  Fico
//
//  Created by Gabriel Tanod on 13/10/25.
//

import Foundation

// MARK: - Data Models

struct DayItem {
    let weekdayShort: String
    let day: Int
    let isToday: Bool
    let isSelected: Bool
}

struct Workout {
    let date: Date
    let durationMin: Int
    let title: String
    let type: String
    let distanceKm: Double
}
