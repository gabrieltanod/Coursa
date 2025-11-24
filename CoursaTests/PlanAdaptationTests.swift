//
//  PlanAdaptationTests.swift
//  CoursaTests
//
//  Focused tests for TRIMP and PlanMapper weekly adaptation using real user data.
//

import XCTest
@testable import Coursa

final class PlanAdaptationTests: XCTestCase {

    // MARK: - Helpers

    private func date(_ str: String) -> Date {
        // Align with app: use Calendar.current and local startOfDay
        let parts = str.split(separator: "-")
        let y = Int(parts[0])!, m = Int(parts[1])!, d = Int(parts[2])!
        var comps = DateComponents()
        comps.year = y; comps.month = m; comps.day = d
        let cal = Calendar.current
        let dt = cal.date(from: comps)!
        return cal.startOfDay(for: dt)
    }

    private func addDays(_ d: Date, _ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: n, to: d)!
    }

    private func sumMinutes(_ runs: [ScheduledRun]) -> Int {
        return runs.reduce(0) { acc, run in
            let sec = run.actual.elapsedSec ?? run.template.targetDurationSec ?? 0
            return acc + Int((Double(sec) / 60.0).rounded())
        }
    }

    // MARK: - Tests

    func testTotalTRIMP_UsesActualElapsedAndAvgHR() {
        // Given a single run with planned 60 min but actually 30 min and avgHR recorded
        var run = ScheduledRun(
            date: date("2025-01-06"),
            template: RunTemplate(
                name: "Easy Run",
                kind: .easy,
                focus: .base,
                targetDurationSec: 60 * 60,
                targetDistanceKm: nil,
                targetHRZone: .z2,
                notes: nil
            )
        )
        run.status = .completed
        run.actual.elapsedSec = 30 * 60
        run.actual.avgHR = 140

        let runs = [run]
        let maxHR: Double = 190
        let gender: TRIMPGender = .male

        // Expected TRIMP computed from actuals (30 min, HR 140)
        let expected = TRIMP.sessionTRIMP(
            durationSec: 30 * 60,
            avgHR: 140,
            maxHR: maxHR,
            gender: gender
        )

        let total = TRIMP.totalTRIMP(for: runs, maxHR: maxHR, gender: gender)
        XCTAssertEqual(total, expected, accuracy: 1e-6)
    }

    func testApplyWeeklyAdaptation_UsesOnboardingAgeGenderAndActuals() {
        // Onboarding: Female, age 30 → maxHR = 190
        OnboardingStore.clear()
        var data = OnboardingData()
        data.personalInfo.age = 30
        data.personalInfo.gender = "Female"
        data.trainingPrefs.selectedDays = [2, 4, 6] // Mon, Wed, Fri
        OnboardingStore.save(data)

        let selectedDays: Set<Int> = [2, 4, 6]
        let frequency = selectedDays.count

        // Build last week and closing week with 150 planned minutes each
        let lastWeekStart = date("2025-01-06") // Monday
        let closingWeekStart = date("2025-01-13")

        var lastWeekRuns = WeeklyPlanner.zone2Week(
            weekStart: lastWeekStart,
            selectedDays: selectedDays,
            frequency: frequency,
            totalZ2Minutes: 150
        )
        var closingWeekRuns = WeeklyPlanner.zone2Week(
            weekStart: closingWeekStart,
            selectedDays: selectedDays,
            frequency: frequency,
            totalZ2Minutes: 150
        )

        // Fill actual metrics: use planned duration, set avgHR for realism
        for i in lastWeekRuns.indices {
            lastWeekRuns[i].status = .completed
            let sec = lastWeekRuns[i].template.targetDurationSec ?? 0
            lastWeekRuns[i].actual.elapsedSec = sec
            lastWeekRuns[i].actual.avgHR = 140
        }
        for i in closingWeekRuns.indices {
            closingWeekRuns[i].status = .completed
            let sec = closingWeekRuns[i].template.targetDurationSec ?? 0
            closingWeekRuns[i].actual.elapsedSec = sec
            closingWeekRuns[i].actual.avgHR = 145 // slightly higher this week
        }

        // Generated plan: last week + closing week
        let allRuns = (lastWeekRuns + closingWeekRuns).sorted { $0.date < $1.date }
        var plan = GeneratedPlan(plan: .endurance, runs: allRuns)

        // Sanity: ensure last run of the closing week is completed (it is)
        XCTAssertTrue(plan.runs.filter { $0.date >= closingWeekStart && $0.date < addDays(closingWeekStart, 7) }.last?.status == .completed)

        // Compute expected TRIMP with derived params
        let maxHR = 190.0
        let gender: TRIMPGender = .female
        let expectedLastWeekTRIMP = TRIMP.totalTRIMP(for: lastWeekRuns, maxHR: maxHR, gender: gender)
        let expectedThisWeekTRIMP = TRIMP.totalTRIMP(for: closingWeekRuns, maxHR: maxHR, gender: gender)
        let lastWeekMinutes = WeeklyPlanner.estimatedWeeklyMinutes(from: lastWeekRuns)
        let expectedNextMinutes = AdaptationEngine.nextWeekMinutes(
            lastWeekTRIMP: expectedLastWeekTRIMP,
            thisWeekTRIMP: expectedThisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes,
            runningFrequency: frequency
        )

        // Run adaptation with now = next Monday
        let now = addDays(closingWeekStart, 7)
        let adapted = PlanMapper.applyWeeklyAdaptationIfDue(
            existing: plan,
            selectedDays: selectedDays,
            now: now,
            onboarding: data
        )

        // Sum minutes for the next week in the adapted plan
        let nextWeekRuns = adapted.runs.filter { $0.date >= now && $0.date < addDays(now, 7) }
        let nextWeekMinutes = WeeklyPlanner.estimatedWeeklyMinutes(from: nextWeekRuns)

        XCTAssertEqual(nextWeekMinutes, expectedNextMinutes)
    }
}
