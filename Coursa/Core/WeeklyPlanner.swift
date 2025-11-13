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

    /// Build a week with a mix of Easy / Long / MAF sessions.
    static func zone2Week(
        weekStart: Date,
        selectedDays: Set<Int>,     // Calendar weekday ints, Mon=2 ... Sun=1
        frequency: Int,
        totalZ2Minutes: Int
    ) -> [ScheduledRun] {
        let days = selectedDays.sorted()
        guard !days.isEmpty else { return [] }

        // 1. Base pattern of session types + nominal minutes
        let pattern = basePattern(for: days.count)
        let totalBase = pattern.reduce(0) { $0 + $1.baseMinutes }

        // 2. Scale pattern so total minutes ~= totalZ2Minutes
        let scale = totalBase > 0 ? Double(totalZ2Minutes) / Double(totalBase) : 1.0
        var scaledMinutes = pattern.map { Int((Double($0.baseMinutes) * scale).rounded()) }

        // 3. Fix rounding mismatch on the last entry
        let diff = totalZ2Minutes - scaledMinutes.reduce(0, +)
        if let lastIndex = scaledMinutes.indices.last, diff != 0 {
            scaledMinutes[lastIndex] = max(10, scaledMinutes[lastIndex] + diff) // keep at least 10 min
        }

        // 4. Build runs for each selected day
        var result: [ScheduledRun] = []
        for (idx, weekday) in days.enumerated() {
            let minutes = max(10, scaledMinutes[idx]) // clip to min duration
            let date = weekStart.dateForWeekday(weekday)
            let tmpl = template(for: pattern[idx].kind, minutes: minutes)
            result.append(ScheduledRun(date: date, template: tmpl))
        }

        return result.sorted { $0.date < $1.date }
    }

    // MARK: - Base pattern and templates

    /// Types of sessions within a week.
    private enum WeekSessionKind {
        case easy
        case long
        case maf
    }

    /// Base mix before scaling to the week's target minutes.
    /// All are Zone-2 from an HR perspective; difference is intent & nominal length.
    private static func basePattern(for slots: Int) -> [(kind: WeekSessionKind, baseMinutes: Int)] {
        switch slots {
        case 1:
            // Only one day: make it a long steady session
            return [(.long, 60)]

        case 2:
            // One shorter easy run + one long
            return [(.easy, 30),
                    (.long, 60)]

        case 3:
            // Classic: Easy, Long, MAF
            return [(.easy, 30),
                    (.long, 60),
                    (.maf, 45)]

        case 4:
            // Easy, Long, MAF, Easy
            return [(.easy, 30),
                    (.long, 60),
                    (.maf, 45),
                    (.easy, 30)]

        default:
            // 5+ days: Easy, Long, MAF, then fill with Easy
            var base: [(WeekSessionKind, Int)] = [
                (.easy, 30),
                (.long, 60),
                (.maf, 45),
                (.easy, 30)
            ]
            while base.count < slots {
                base.append((.easy, 30))
            }
            return Array(base.prefix(slots))
        }
    }

    private static func template(for kind: WeekSessionKind, minutes: Int) -> RunTemplate {
        let sec = minutes * 60

        switch kind {
        case .easy:
            return RunTemplate(
                name: "Easy Run",
                kind: .easy,
                focus: .base,
                targetDurationSec: sec,
                targetDistanceKm: nil,
                targetHRZone: .z2,
                notes: "Relaxed Zone 2 effort. Focus on smooth form and controlled breathing."
            )

        case .long:
            return RunTemplate(
                name: "Long Run",
                kind: .long,
                focus: .endurance,
                targetDurationSec: sec,
                targetDistanceKm: nil,
                targetHRZone: .z2,
                notes: "Extended Zone 2 session to build aerobic endurance and mental stamina."
            )

        case .maf:
            return RunTemplate(
                name: "MAF Training",
                kind: .maf,
                focus: .endurance,
                targetDurationSec: sec,
                targetDistanceKm: nil,
                targetHRZone: .z2,
                notes: "Steady Zone 2 run near aerobic threshold. Stay controlled and efficient."
            )
        }
    }

    private static func runDurationSec(_ run: ScheduledRun) -> Int? {
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
