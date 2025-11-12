//
//  AdaptationCoordinator.swift
//  Coursa
//
//  Created by Gabriel Tanod on 13/11/25.
//
//  Summary
//  -------
//  Coordinates "run completed" events and schedules weekly adaptation
//  execution for +2 hours later when the final run of a week is done.
//

import Foundation

enum AdaptationCoordinator {
    private static let pendingKey = "coursa.adaptation.pendingAt"

    static func scheduleIfLastRunOfWeekCompleted(
        plan: GeneratedPlan,
        completedRun: ScheduledRun
    ) {
        let weekStart = completedRun.date.mondayFloor()
        let isLast = isLastRunOfWeekCompleted(plan: plan, weekStart: weekStart)
        guard isLast else { return }
        let fireAt = Date().addingTimeInterval(2 * 60 * 60) // +2 hours
        UserDefaults.standard.set(fireAt.timeIntervalSince1970, forKey: pendingKey)
    }

    static func runIfDue(
        selectedDays: Set<Int>,
        store: PlanStore
    ) {
        let now = Date()
        let ts = UserDefaults.standard.double(forKey: pendingKey)
        guard ts > 0 else { return }
        let due = Date(timeIntervalSince1970: ts)
        guard now >= due, let plan = store.load() else { return }

        let updated = PlanMapper.applyWeeklyAdaptationIfDue(
            existing: plan,
            selectedDays: selectedDays,
            now: now
        )
        store.save(updated)
        UserDefaults.standard.removeObject(forKey: pendingKey)
    }
}

// local helpers
private func isLastRunOfWeekCompleted(plan: GeneratedPlan, weekStart: Date) -> Bool {
    let weekEnd = weekStart.addingDays(7)
    let week = plan.runs.filter { $0.date >= weekStart && $0.date < weekEnd }
    guard !week.isEmpty else { return false }
    guard let last = week.max(by: { $0.date < $1.date }) else { return false }
    return last.status == .completed
}
private extension Date {
    func mondayFloor() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        let weekday = cal.component(.weekday, from: self)
        let delta = (weekday == 1) ? -6 : (2 - weekday)
        let start = cal.date(byAdding: .day, value: delta, to: self)!
        return cal.startOfDay(for: start)
    }
    func addingDays(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: n, to: self)!
    }
}
