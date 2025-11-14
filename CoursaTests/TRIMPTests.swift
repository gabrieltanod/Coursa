//
//  TRIMPTests.swift
//  Coursa
//
//  Created by Gabriel Tanod on 13/11/25.
//
//  AdaptationEngineTests.swift
//  CoursaTests
//
//  Uses Swift Testing (no XCTest).
//

import Foundation
import Testing

@testable import Coursa  // change to your app module name

struct TRIMPTests {

    @Test
    func
        applyWeeklyAdaptationIfDue_increasesNextWeekWithinCap_whenTrimpInTargetRange()
        async throws
    {
        let cal = Calendar(identifier: .gregorian)

        // Use a fixed Monday so mondayFloor() matches our week starts.
        var comps = DateComponents()
        comps.year = 2025
        comps.month = 1
        comps.day = 6  // Monday
        comps.hour = 0
        comps.minute = 0
        comps.second = 0

        let week1Start = cal.date(from: comps)!  // Mon 6 Jan
        let week2Start = week1Start.addingTimeInterval(7 * 24 * 60 * 60)  // Mon 13 Jan
        let week3Start = week2Start.addingTimeInterval(7 * 24 * 60 * 60)  // Mon 20 Jan

        // Mon / Wed / Fri in Calendar.weekday space
        let selectedDays: Set<Int> = [2, 4, 6]

        // Helper: build a week of 3 completed Z2 runs with equal durations.
        func makeWeek(start: Date, totalMinutes: Int) -> [ScheduledRun] {
            let days = selectedDays.sorted()
            let per = totalMinutes / days.count

            func dateForWeekday(from weekStart: Date, weekday: Int) -> Date {
                for offset in 0..<7 {
                    let d = cal.date(byAdding: .day, value: offset, to: weekStart)!
                    if cal.component(.weekday, from: d) == weekday {
                        return d
                    }
                }
                return weekStart
            }

            return days.map { weekday in
                let date = dateForWeekday(from: start, weekday: weekday)

                let template = RunTemplate(
                    name: "Easy Run",
                    kind: .easy,
                    focus: .base,
                    targetDurationSec: per * 60,
                    targetDistanceKm: nil,
                    targetHRZone: .z2,
                    notes: nil
                )

                var run = ScheduledRun(date: date, template: template)
                // Treat as fully completed in Zone 2
                run.status = .completed
                run.actual.elapsedSec = per * 60
                run.actual.avgHR = 130  // ~mid Zone 2 for default HRmax=200
                return run
            }
        }

        // Baseline: both week 1 and week 2 have the same minutes & TRIMP,
        // so TRIMP ratio ~ 1.0 => overloadFactor = 1.05 (good progression).
        let baseWeeklyMinutes = 150
        let week1Runs = makeWeek(
            start: week1Start,
            totalMinutes: baseWeeklyMinutes
        )
        let week2Runs = makeWeek(
            start: week2Start,
            totalMinutes: baseWeeklyMinutes
        )

        // Pre-existing week 3 (will be replaced by adaptation)
        let week3RunsOriginal = makeWeek(
            start: week3Start,
            totalMinutes: baseWeeklyMinutes
        )

        var allRuns = week1Runs + week2Runs + week3RunsOriginal
        allRuns.sort { $0.date < $1.date }

        let existing = GeneratedPlan(plan: .baseBuilder, runs: allRuns)

        // Sanity: totals before adaptation.
        let baseWeek1Minutes = sumMinutes(in: existing, weekStart: week1Start)
        let baseWeek2Minutes = sumMinutes(in: existing, weekStart: week2Start)
        #expect(baseWeek1Minutes == baseWeeklyMinutes)
        #expect(baseWeek2Minutes == baseWeeklyMinutes)

        // Now we simulate "now" = Monday of week 3.
        let adapted = PlanMapper.applyWeeklyAdaptationIfDue(
            existing: existing,
            selectedDays: selectedDays,
            now: week3Start
        )

        // 1) Weeks before week3Start must be unchanged (history locked).
        let lockedOriginal = existing.runs.filter { $0.date < week3Start }
        let lockedAdapted = adapted.runs.filter { $0.date < week3Start }
        #expect(lockedOriginal.count == lockedAdapted.count)

        for (lhs, rhs) in zip(lockedOriginal, lockedAdapted) {
            #expect(lhs.id == rhs.id)
            #expect(lhs.date == rhs.date)
            #expect(
                lhs.template.targetDurationSec == rhs.template.targetDurationSec
            )
            #expect(lhs.status == rhs.status)
        }

        // 2) Week 3 should be regenerated with more minutes than baseline,
        //    but still within the +10% cap.
        let newWeek3Minutes = sumMinutes(in: adapted, weekStart: week3Start)
        let originalWeek3Minutes = sumMinutes(
            in: existing,
            weekStart: week3Start
        )

        #expect(
            originalWeek3Minutes == baseWeeklyMinutes,
            "Original week 3 should match baseline"
        )
        #expect(
            newWeek3Minutes > baseWeeklyMinutes,
            "Week 3 should increase load after good TRIMP progression"
        )
        #expect(
            newWeek3Minutes
                <= Int((Double(baseWeeklyMinutes) * 1.10).rounded()),
            "Week 3 must respect the +10% cap"
        )

        // 3) All week 3 sessions must remain Zone 2 as per v1 design.
        let newWeek3Runs = runs(in: adapted, weekStart: week3Start)
        #expect(!newWeek3Runs.isEmpty, "Week 3 should exist after adaptation")
        for run in newWeek3Runs {
            #expect(run.template.targetHRZone == .z2)
        }
    }

    @Test
    func trimpIsZeroWhenNoDuration() {
        let value = TRIMP.sessionTRIMP(
            durationSec: 0,
            avgHR: 140,
            maxHR: 200,
            gender: .male
        )

        #expect(value == 0)
    }

    @Test
    func trimpIncreasesWithDuration() {
        let short = TRIMP.sessionTRIMP(
            durationSec: 30 * 60,  // 30 min
            avgHR: 140,
            maxHR: 200,
            gender: .male
        )
        let long = TRIMP.sessionTRIMP(
            durationSec: 60 * 60,  // 60 min
            avgHR: 140,
            maxHR: 200,
            gender: .male
        )

        #expect(long > short)
    }

    @Test
    func trimpIncreasesWithIntensity() {
        let low = TRIMP.sessionTRIMP(
            durationSec: 45 * 60,
            avgHR: 130,
            maxHR: 200,
            gender: .male
        )
        let high = TRIMP.sessionTRIMP(
            durationSec: 45 * 60,
            avgHR: 170,
            maxHR: 200,
            gender: .male
        )

        #expect(high > low)
    }
}

struct AdaptationEngineTests {

    // Helper to keep numbers readable
    private func nextWeekMinutes(
        lastWeekTRIMP: Double,
        thisWeekTRIMP: Double,
        lastWeekMinutes: Int,
        runningFrequency: Int = 3
    ) -> Int {
        AdaptationEngine.nextWeekMinutes(
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes,
            runningFrequency: runningFrequency
        )
    }

    @Test
    func undertrainedRepeatsWeek() {
        // PRD: WeeklyTRIMP < lastWeekTRIMP * 0.9 → overloadFactor = 1.0 (repeat week)
        let lastWeekTRIMP = 100.0
        let thisWeekTRIMP = 80.0  // 0.8 * lastWeekTRIMP
        let lastWeekMinutes = 150

        let next = nextWeekMinutes(
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes
        )

        #expect(next == lastWeekMinutes)
    }

    @Test
    func overreachedRepeatsWeek() {
        // PRD: WeeklyTRIMP > lastWeekTRIMP * 1.2 → overloadFactor = 1.0 (repeat week)
        let lastWeekTRIMP = 100.0
        let thisWeekTRIMP = 130.0  // 1.3 * lastWeekTRIMP
        let lastWeekMinutes = 150

        let next = nextWeekMinutes(
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes
        )

        #expect(next == lastWeekMinutes)
    }

    @Test
    func goodProgressIncreasesByAboutFivePercent() {
        // PRD: WeeklyTRIMP in [1.0, 1.1] * lastWeekTRIMP → overloadFactor = 1.05
        let lastWeekTRIMP = 100.0
        let thisWeekTRIMP = 105.0  // inside [1.0, 1.1] window
        let lastWeekMinutes = 150

        let next = nextWeekMinutes(
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes
        )

        // 150 * 1.05 = 157.5 → ~158
        #expect(next >= 157 && next <= 160)
    }

    @Test
    func growthIsCappedAtTenPercent() {
        // Even if math tried to push more, final value must be <= 110% of lastWeekMinutes
        let lastWeekTRIMP = 100.0
        let thisWeekTRIMP = 105.0
        let lastWeekMinutes = 200

        let next = nextWeekMinutes(
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes
        )

        let maxAllowed = Int((Double(lastWeekMinutes) * 1.10).rounded())
        #expect(next <= maxAllowed)
    }
}

private func runs(in plan: GeneratedPlan, weekStart: Date) -> [ScheduledRun] {
    let weekEnd = weekStart.addingTimeInterval(7 * 24 * 60 * 60)
    return plan.runs.filter { $0.date >= weekStart && $0.date < weekEnd }
}

private func sumMinutes(in plan: GeneratedPlan, weekStart: Date) -> Int {
    sumMinutes(runs: runs(in: plan, weekStart: weekStart))
}

private func sumMinutes(runs: [ScheduledRun]) -> Int {
    runs.reduce(0) { acc, run in
        let sec = run.actual.elapsedSec ?? run.template.targetDurationSec ?? 0
        return acc + Int((Double(sec) / 60.0).rounded())
    }
}
