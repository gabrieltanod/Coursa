//
//  WeeklyPlanner.swift
//  Coursa
//
//  Created by Gabriel Tanod on 12/11/25.
//
//  Summary
//  -------
//  Splits a weekly Zone-2 minute target across the user's selected days,
//  producing simple Session blueprints (all Zone-2).
//
//  Responsibilities
//  ----------------
//  - Input: total minutes target and selected weekdays.
//  - Output: per-day durations for next week's sessions (Zone-2 only).
//  - Keep distribution even; small remainder goes to the longest day.
//

import Foundation

enum WeeklyPlanner {
    /// v1 seed when no prior week found or no data.
    static let defaultZ2MinutesSeed: Int = 150  // ~ 3 x 40 + 1 x 30, etc.

    /// Estimates last week's planned minutes if completion data is poor.
    static func estimatedWeeklyMinutes(from runs: [ScheduledRun]) -> Int {
        let sumSec = runs.reduce(0) { $0 + (runDurationSec($1) ?? 0) }
        return Int((Double(sumSec) / 60.0).rounded())
    }

    static func zone2Week(
        weekStart: Date,
        selectedDays: Set<Int>,     // Calendar weekday ints, Mon=2 ... Sun=1
        frequency: Int,
        totalZ2Minutes: Int
    ) -> [ScheduledRun] {
        let days = selectedDays.sorted()
        guard !days.isEmpty else { return [] }

        let per = totalZ2Minutes / days.count
        let extra = totalZ2Minutes % days.count

        var result: [ScheduledRun] = []
        for (idx, weekday) in days.enumerated() {
            let minutes = per + (idx == days.count - 1 ? extra : 0) // remainder to last day
            let date = weekStart.dateForWeekday(weekday)
            let tmpl = zone2Template(minutes: minutes)
            result.append(ScheduledRun(date: date, template: tmpl))
        }
        return result.sorted { $0.date < $1.date }
    }

    private static func zone2Template(minutes: Int) -> RunTemplate {
        RunTemplate(
            name: "Easy Run",
            kind: .easy,
            focus: .base,
            targetDurationSec: minutes * 60,
            targetDistanceKm: nil,
            targetHRZone: .z2,
            notes: "Steady Zone 2 run."
        )
    }

    private static func runDurationSec(_ run: ScheduledRun) -> Int? {
        // prefer actual if present, else target
        if let s = run.actual.elapsedSec { return s }
        return run.template.targetDurationSec
    }
}

// MARK: - Date helpers (Monday week)

private extension Date {
    func dateForWeekday(_ weekday: Int) -> Date {
        // weekday: 1=Sun, 2=Mon, ... 7=Sat
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // Monday
        let base = self
        for i in 0..<7 {
            let d = base.addingDays(i)
            if cal.component(.weekday, from: d) == weekday {
                return d
            }
        }
        return base
    }
    func addingDays(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: n, to: self)!
    }
}
