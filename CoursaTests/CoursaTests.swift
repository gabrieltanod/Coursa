//
//  CoursaTests.swift
//  Coursa
//
//  Created by Gabriel Tanod on 13/10/25.
//
//  Summary
//  -------
//  Swift Testing test suite validating the dynamic plan engine:
//  - WeeklyPlanner: distributions & zone assignment
//  - PlanMapper.regeneratePlan: preserves history, rebuilds future
//  - PlanMapper.applyWeeklyAdaptationIfDue: weekly adaptation with +10% cap
//  - TRIMP: basic load calculation
//
//  Notes
//  -----
//  Tests pin time to known Mondays for deterministic outcomes.
//  These tests avoid onboarding types and construct plans directly.
//
//  Requires: Swift Testing (`import Testing`), access to Coursa types.
//

import Foundation
import Testing
@testable import Coursa

struct CoursaTests {

    // MARK: - Helpers (dates, builders)

    /// Returns a fixed Monday at 07:00 local to avoid DST surprises.
    private func monday(_ year: Int = 2025, _ month: Int = 1, _ day: Int = 6) -> Date {
        var comps = DateComponents()
        comps.year = year; comps.month = month; comps.day = day
        comps.hour = 7; comps.minute = 0; comps.second = 0
        return Calendar.current.date(from: comps)!
    }

    private func weekday(_ d: Date) -> Int {
        Calendar.current.component(.weekday, from: d)
    }

    /// Convenience to make a simple Z2 template of N minutes.
    private func z2Template(_ minutes: Int, name: String = "Easy Run") -> RunTemplate {
        RunTemplate(
            name: name,
            kind: .easy,
            focus: .base,
            targetDurationSec: minutes * 60,
            targetDistanceKm: nil,
            targetHRZone: .z2,
            notes: "Test Z2"
        )
    }

    /// Builds a ScheduledRun at date with a Z2 template (minutes).
    private func makeRun(_ date: Date, minutes: Int) -> ScheduledRun {
        ScheduledRun(date: date, template: z2Template(minutes))
    }

    /// Build one full week using WeeklyPlanner with given days & total minutes.
    private func buildWeek(weekStart: Date, selectedDays: Set<Int>, totalMin: Int) -> [ScheduledRun] {
        WeeklyPlanner.zone2Week(
            weekStart: weekStart,
            selectedDays: selectedDays,
            frequency: max(selectedDays.count, 1),
            totalZ2Minutes: totalMin
        )
    }

    /// Sum planned or actual minutes for runs in a slice.
    private func sumMinutes(_ runs: [ScheduledRun]) -> Int {
        runs.reduce(0) { acc, run in
            let sec = run.actual.elapsedSec ?? (run.template.targetDurationSec ?? 0)
            return acc + Int(round(Double(sec) / 60.0))
        }
    }

    // MARK: - WeeklyPlanner

    @Test
    func weeklyPlanner_distributesEvenly_allZ2() async throws {
        let weekStart = monday(2025, 1, 6) // a Monday
        let days: Set<Int> = [2, 4, 6]     // Mon, Wed, Fri
        let week = buildWeek(weekStart: weekStart, selectedDays: days, totalMin: 150)

        #expect(week.count == 3, "Should create exactly 3 sessions")
        // Ensure weekdays match requested days & are Zone 2
        for run in week {
            #expect(days.contains(weekday(run.date)))
            #expect(run.template.targetHRZone == .z2)
        }
        // Even-ish distribution: 150 → 50/50/50 (remainder to last day already handled)
        #expect(sumMinutes(week) == 150)
    }

    // MARK: - PlanMapper.regeneratePlan

//    @Test
//    func regenerate_preservesPast_rebuildsFutureOnNewDays() async throws {
//        let start = monday(2025, 1, 6)                // Week 1 start
//        let w1 = buildWeek(weekStart: start, selectedDays: [2,4,6], totalMin: 150)
//        let w2 = buildWeek(weekStart: start.addingDays(7), selectedDays: [2,4,6], totalMin: 150)
//        var plan = GeneratedPlan(plan: .endurance, runs: (w1 + w2).sorted { $0.date < $1.date })
//
//        // Mark all week 1 runs completed to simulate history
//        for i in 0..<w1.count {
//            if let idx = plan.runs.firstIndex(where: { $0.id == w1[i].id }) {
//                plan.runs[idx].status = .completed
//                plan.runs[idx].actual.elapsedSec = plan.runs[idx].template.targetDurationSec
//                plan.runs[idx].actual.avgHR = 130
//            }
//        }
//
//        // Today is Monday of Week 2 → Week 1 is "past"
//        let today = start.addingDays(7)
//        let pastSnapshot = plan.runs.filter { $0.date < today }.map { ($0.id, $0.date, $0.status) }
//
//        // Change schedule to Tue/Thu/Sat; regenerate future
//        let updated = PlanMapper.regeneratePlan(
//            existing: plan,
//            newPlan: .endurance,
//            newSelectedDays: [3,5,7],
//            today: today
//        )
//
//        // Past must be intact (ids/dates/statuses)
//        let updatedPast = updated.runs.filter { $0.date < today }.map { ($0.id, $0.date, $0.status) }
//        #expect(updatedPast == pastSnapshot, "Past sessions should remain unchanged")
//
//        // Future (>= today) should only be on Tue/Thu/Sat
//        let future = updated.runs.filter { $0.date >= today }
//        for run in future {
//            #expect([3,5,7].contains(weekday(run.date)), "Future run not on selected day")
//        }
//    }

    // MARK: - PlanMapper.applyWeeklyAdaptationIfDue (+10% cap)

    @Test
    func adaptation_rebuildsNextWeek_withTenPercentCap() async throws {
        let start = monday(2025, 1, 6)                // Week 1
        let week1 = buildWeek(weekStart: start, selectedDays: [2,4,6], totalMin: 150)
        // Prebuild a placeholder next week so we can observe replacement
        let week2Pre = buildWeek(weekStart: start.addingDays(7), selectedDays: [2,4,6], totalMin: 150)

        var plan = GeneratedPlan(plan: .endurance, runs: (week1 + week2Pre).sorted { $0.date < $1.date })

        // Complete the last run of week 1 (and the others) so adaptation is eligible
        for i in 0..<week1.count {
            if let idx = plan.runs.firstIndex(where: { $0.id == week1[i].id }) {
                plan.runs[idx].status = .completed
                plan.runs[idx].actual.elapsedSec = plan.runs[idx].template.targetDurationSec
                plan.runs[idx].actual.avgHR = 140 // around mid Z2
            }
        }

        // Simulate "now" as Monday of Week 2 (the regeneration window)
        let now = start.addingDays(7) // Monday 00:00 of week 2
        let updated = PlanMapper.applyWeeklyAdaptationIfDue(
            existing: plan,
            selectedDays: [2,4,6],
            now: now
        )

        // The next week should be regenerated at +10% minutes => 165 minutes total
        let week2 = updated.runs.filter { $0.date >= now && $0.date < now.addingDays(7) }
        #expect(!week2.isEmpty, "Week 2 should exist after adaptation")
        #expect(sumMinutes(week2) == 165, "Week 2 should total 165 minutes (+10%)")
        for run in week2 {
            #expect(run.template.targetHRZone == .z2, "All sessions must remain Zone 2 in v1")
        }
    }

    // MARK: - TRIMP

    @Test
    func trimp_usesAvgHR_whenAvailable_elseZ2Mid() async throws {
        // 60 minutes at avgHR 140 with HRmax 200 → intensity ~0.7 → TRIMP ~42
        let tr1 = TRIMP.sessionTRIMP(durationMin: 60, avgHR: 140)
        #expect(abs(tr1 - 42.0) < 0.5)

        // 30 minutes no HR → fallback to Z2 midpoint (~0.65) → ~19.5
        let tr2 = TRIMP.sessionTRIMP(durationMin: 30, avgHR: nil)
        #expect(abs(tr2 - 19.5) < 0.5)
    }
    
    
    // Test: WeeklyPlanner should NOT generate all Easy runs
    @Test
    func weeklyPlanner_generatesMixedSessionTypes() async throws {
        let weekStart = Date().testMondayFloor()
        let selected: Set<Int> = [2,4,6] // Mon, Wed, Fri (3 days)
        let runs = WeeklyPlanner.zone2Week(
            weekStart: weekStart,
            selectedDays: selected,
            frequency: 3,
            totalZ2Minutes: 150
        )

        #expect(runs.count == 3)
        let kinds = runs.map { $0.template.kind }
        #expect(kinds.contains(.easy))
        #expect(kinds.contains(.long))
        #expect(kinds.contains(.maf))
    }
}

// MARK: - Date helpers for tests

private extension Date {
    func addingDays(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: n, to: self)!
    }
    func testMondayFloor() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        let weekday = cal.component(.weekday, from: self)
        let delta = (weekday == 1) ? -6 : (2 - weekday)
        let start = cal.date(byAdding: .day, value: delta, to: self)!
        return cal.startOfDay(for: start)
    }
}
