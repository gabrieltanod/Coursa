//
//  StatisticsModels.swift
//  Coursa
//
//  Created by Gabriel Tanod on 03/12/25.
//

import Foundation

struct PlanProgressData {
    let title: String
    let progress: Double
    let completedKm: Double
    let targetKm: Double
}

struct WeeklyMetricsData {
    let thisWeekPace: String
    let lastWeekPace: String
    let paceTrend: ComparisonTrend?
    let thisWeekAerobic: String
    let lastWeekAerobic: String
    let aerobicTrend: ComparisonTrend?
    let summaryMessage: String
}
