//
//  StatisticsViewModel.swift
//  Coursa
//
//  Created by Gabriel Tanod on 03/12/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class StatisticsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var showAerobicInfo = false
    
    // Data for View binding
    @Published var planProgress: PlanProgressData?
    @Published var weeklyMetrics: WeeklyMetricsData?
    @Published var recentRuns: [ScheduledRun] = []
    @Published var hasRecentActivity: Bool = false
    
    // MARK: - Dependencies
    private let planSession: PlanSessionStore
    private var cancellables = Set<AnyCancellable>()
    
    init(planSession: PlanSessionStore = PlanSessionStore()) {
        self.planSession = planSession
        
        planSession.$generatedPlan
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.recalculateStatistics()
            }
            .store(in: &cancellables)
            
        recalculateStatistics()
    }
        
    private func recalculateStatistics() {
        let allRuns = planSession.allRuns.sorted { $0.date < $1.date }
        
        calculatePlanProgress(allRuns: allRuns)
        
        calculateWeeklyMetrics(allRuns: allRuns)
        
        calculateRecentActivity(allRuns: allRuns)
    }
    
    private func calculatePlanProgress(allRuns: [ScheduledRun]) {
        let totalSessions = allRuns.count
        let completedOrSkippedSessions = allRuns.filter {
            $0.status == .completed || $0.status == .skipped
        }.count

        let progress = totalSessions == 0 ? 0 : Double(completedOrSkippedSessions) / Double(totalSessions)

        let completedKm = allRuns
            .filter { $0.status == .completed }
            .reduce(0.0) { sum, run in
                if let d = run.actual.distanceKm { return sum + d }
                if let t = run.template.targetDistanceKm { return sum + t }
                return sum
            }

        let targetKm = allRuns
            .compactMap { $0.template.targetDistanceKm }
            .reduce(0, +)

        let title = planTitle(from: allRuns)
        
        self.planProgress = PlanProgressData(
            title: title,
            progress: progress,
            completedKm: completedKm,
            targetKm: targetKm
        )
    }
    
    private func calculateWeeklyMetrics(allRuns: [ScheduledRun]) {
        let completedRuns = allRuns
            .filter { $0.status == .completed }
            .sorted { $0.date > $1.date }

        let cal = Calendar.current
        let now = Date()

        // Week ranges
        let thisWeekStart = cal.dateInterval(of: .weekOfYear, for: now)!.start
        let lastWeekStart = cal.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart)!
        let lastWeekEnd = thisWeekStart

        // Filter runs by week
        let thisWeekRuns = completedRuns.filter { $0.date >= thisWeekStart }
        let lastWeekRuns = completedRuns.filter { $0.date >= lastWeekStart && $0.date < lastWeekEnd }

        // Compute average paces
        let thisWeekPaceSec = computeAveragePace(for: thisWeekRuns)
        let lastWeekPaceSec = computeAveragePace(for: lastWeekRuns)

        // Format
        let thisWeekPaceText = formatPace(thisWeekPaceSec)
        let lastWeekPaceText = formatPace(lastWeekPaceSec)

        let thisWeekZone2Seconds = totalZone2SecondsForWeek(offset: 0)
        let lastWeekZone2Seconds = totalZone2SecondsForWeek(offset: 1)

        let thisWeekAerobicText = formatHMS(thisWeekZone2Seconds)
        let lastWeekAerobicText = formatHMS(lastWeekZone2Seconds)

        let paceTrend: ComparisonTrend? = {
            if thisWeekPaceSec <= 0 || lastWeekPaceSec <= 0 { return nil }
            if thisWeekPaceSec < lastWeekPaceSec { return .better }
            else if thisWeekPaceSec > lastWeekPaceSec { return .worse }
            else { return .same }
        }()

        let aerobicTrend: ComparisonTrend? = {
            if thisWeekZone2Seconds == 0 && lastWeekZone2Seconds == 0 { return nil }
            if thisWeekZone2Seconds > lastWeekZone2Seconds { return .better }
            else if thisWeekZone2Seconds < lastWeekZone2Seconds { return .worse }
            else { return .same }
        }()
        
        let summaryMessage = getSummaryMessage(paceTrend: paceTrend, aerobicTrend: aerobicTrend)
        
        self.weeklyMetrics = WeeklyMetricsData(
            thisWeekPace: thisWeekPaceText,
            lastWeekPace: lastWeekPaceText,
            paceTrend: paceTrend,
            thisWeekAerobic: thisWeekAerobicText,
            lastWeekAerobic: lastWeekAerobicText,
            aerobicTrend: aerobicTrend,
            summaryMessage: summaryMessage
        )
    }
    
    private func calculateRecentActivity(allRuns: [ScheduledRun]) {
        let historyRuns = allRuns
            .filter { $0.status == .completed || $0.status == .skipped }
            .sorted { $0.date > $1.date }
        
        self.recentRuns = Array(historyRuns.prefix(3))
        self.hasRecentActivity = !self.recentRuns.isEmpty
    }
        
    private func planTitle(from runs: [ScheduledRun]) -> String {
        guard let focus = runs.first?.template.focus else { return "Your Plan" }
        switch focus {
        case .base, .endurance: return "Endurance Plan"
        case .speed: return "Speed Plan"
        default: return "Your Plan"
        }
    }
    
    private func computeAveragePace(for runs: [ScheduledRun]) -> Double {
        let paceValues: [Double] = runs.compactMap { run in
            guard let distance = run.actual.distanceKm, distance > 0,
                  let duration = run.actual.elapsedSec else { return nil }
            return Double(duration) / distance
        }
        guard !paceValues.isEmpty else { return 0 }
        return paceValues.reduce(0, +) / Double(paceValues.count)
    }
    
    private func totalZone2SecondsForWeek(offset: Int) -> Int {
        let calendar = Calendar.current
        let now = Date()

        guard let thisWeekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else { return 0 }

        let targetStart: Date
        if offset == 0 {
            targetStart = thisWeekInterval.start
        } else {
            guard let shifted = calendar.date(byAdding: .weekOfYear, value: -offset, to: thisWeekInterval.start),
                  let interval = calendar.dateInterval(of: .weekOfYear, for: shifted) else { return 0 }
            targetStart = interval.start
        }

        guard let targetEnd = calendar.date(byAdding: .day, value: 7, to: targetStart) else { return 0 }
        let interval = DateInterval(start: targetStart, end: targetEnd)

        let weekRuns = planSession.allRuns.filter { interval.contains($0.date) }
        let totalSecondsDouble = weekRuns.reduce(0.0) { partial, run in
            let z2 = run.actual.zoneDuration[2] ?? 0
            return partial + z2
        }

        return Int(totalSecondsDouble)
    }
    
    private func formatHMS(_ seconds: Int) -> String {
        guard seconds > 0 else { return "0:00:00" }
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    private func formatPace(_ secondsPerKm: Double) -> String {
        if secondsPerKm <= 0 { return "0:00/km" }
        let minutes = Int(secondsPerKm) / 60
        let seconds = Int(secondsPerKm) % 60
        return String(format: "%d:%02d/km", minutes, seconds)
    }
    
    private func getSummaryMessage(paceTrend: ComparisonTrend?, aerobicTrend: ComparisonTrend?) -> String {
        switch (paceTrend, aerobicTrend) {
        case (.better, .better):
            return "Amazing job! You’ve managed to keep up both your aerobic and pace. Keep it this way and you’ll reach your goal in no time!"
        case (.better, _):
            return "You’ve increased your pace, but your aerobic time can be better. The first priority is to build your endurance first. Keep up the good work."
        case (_, .better):
            return "Great job at increasing aerobic time, although you can put more effort in your pace. The first priority is to build your endurance first. Keep up the good work."
        case (.worse, .worse):
            return "That week was fantastic for logging consistent work, even if your pace and aerobic time didn't show big jumps. Remember, sticking to the schedule is a huge win for building long-term fitness!"
        default:
            return ""
        }
    }
}
