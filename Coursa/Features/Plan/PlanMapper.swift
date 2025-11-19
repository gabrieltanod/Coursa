//
//  PlanMapper.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//
//  Summary
//  -------
//  PlanMapper converts plan intent (selected goal, start date, chosen days)
//  into concrete, chronological runs. It also supports safe, partial
//  regeneration of only-future sessions and a weekly adaptation flow.
//  Weeks are Monday-based; regeneration is capped to 16 weeks and Zone-2-only.
//
//  Responsibilities
//  ----------------
//  - Initial plan generation during onboarding (still returns [ScheduledRun]).
//  - "Preserve the past" rule: keep completed/skipped/old sessions intact.
//  - Weekly adaptation: after the last run of a week completes (+2h), compute
//    next week’s target with +10% cap and generate runs on selected days.
//  - Enforce max horizon (16 weeks), Zone-2-only v1.
//

import Foundation
import SwiftUI

// MARK: - Public API

enum PlanMapper {
    
    // === Onboarding ===
    static func generatePlan(from data: OnboardingData) -> GeneratedPlan? {
        guard
            let selectedPlan = data.selectedPlan ?? data.recommendedPlan,
            !data.trainingPrefs.selectedDays.isEmpty
        else { return nil }
        
        // v1 keeps your original length logic for first build
        let frequency     = data.trainingPrefs.daysPerWeek
        let durationWeeks = selectedPlan == .halfMarathonPrep ? 10 : 8
        let totalSessions = frequency * durationWeeks
        let weekTemplate  = weekTemplate(for: selectedPlan, frequency: frequency)
        
        let runs = makeSchedule(
            template: weekTemplate,
            startDate: data.startDate.mondayFloor(),               // monday-based
            selectedDays: data.trainingPrefs.selectedDays,
            totalSessions: totalSessions
        )
        return GeneratedPlan(plan: selectedPlan, runs: runs)
    }
    
    // === Manage Plan / schedule change (preserve past) ===
    static func regeneratePlan(
        existing: GeneratedPlan,
        newPlan: Plan? = nil,
        newSelectedDays: Set<Int>,
        today: Date = Date()
    ) -> GeneratedPlan {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: today)
        
        // 1) Lock history
        let locked = existing.runs.filter { $0.date < todayStart }
        
        // 2) Keep plan or swap if changed
        let plan = newPlan ?? existing.plan
        
        // 3) Determine remaining horizon: stop at 16 weeks from first week start
        let planStart = (existing.runs.first?.date ?? todayStart).mondayFloor()
        let endLimit  = planStart.addingWeeks(16)  // hard stop after 16 weeks
        
        // 4) Frequency from selected days
        let frequency = max(newSelectedDays.count, 1)
        
        // 5) Build future from today to endLimit using Zone-2-only weekly planner
        var future: [ScheduledRun] = []
        var cursor = todayStart.mondayFloor() // start next/full week from this Monday
        
        // If we’re mid-week, still plan sessions >= today (preserve exact future boundary)
        while cursor < endLimit {
            let nextWeekSessions = WeeklyPlanner.zone2Week(
                weekStart: cursor,
                selectedDays: newSelectedDays,
                frequency: frequency,
                // Seed: keep simple—use your previous typical total (~150min) for v1
                totalZ2Minutes: WeeklyPlanner.defaultZ2MinutesSeed
            )
            future += nextWeekSessions.filter { $0.date >= todayStart }
            cursor = cursor.addingWeeks(1)
        }
        
        // 6) Stitch back (keep chronology)
        let all = (locked + future).sorted { $0.date < $1.date }
        return GeneratedPlan(plan: plan, runs: all)
    }
    
    // === Weekly adaptation application ===
    // Call this when the scheduled +2h job fires after the last run of a week.
    static func applyWeeklyAdaptationIfDue(
        existing: GeneratedPlan,
        selectedDays: Set<Int>,
        now: Date = Date()
    ) -> GeneratedPlan {
        // If already beyond 16 weeks, bail
        guard let first = existing.runs.first else { return existing }
        let planStart = first.date.mondayFloor()
        let limit     = planStart.addingWeeks(16)
        if now >= limit { return existing }
        
        // Find the week that just closed (the previous Monday week)
        let closingWeekStart = now.mondayFloor().addingWeeks(-1)
        let closingWeekEnd   = closingWeekStart.addingDays(7)
        
        // If user did not complete the last run of that week, do nothing.
        guard isLastRunOfWeekCompleted(plan: existing, weekStart: closingWeekStart) else {
            return existing
        }
        
        // Sum TRIMP for the closing week (this week)
        let thisWeekRuns = runs(in: existing, weekStart: closingWeekStart)
        guard !thisWeekRuns.isEmpty else { return existing }
        
        let thisWeekTRIMP = TRIMP.totalTRIMPUsingDefaults(for: thisWeekRuns)
        
        // Look one week back to get last week's TRIMP and minutes, if available.
        let lastWeekStart = closingWeekStart.addingWeeks(-1)
        let lastWeekRuns = runs(in: existing, weekStart: lastWeekStart)
        
        let lastWeekTRIMP: Double
        let lastWeekMinutes: Int
        
        if !lastWeekRuns.isEmpty {
            // Normal case: we have a previous training week.
            lastWeekTRIMP = TRIMP.totalTRIMPUsingDefaults(for: lastWeekRuns)
            lastWeekMinutes = WeeklyPlanner.estimatedWeeklyMinutes(from: lastWeekRuns)
        } else {
            // First adaptive week: treat the closing week as baseline.
            lastWeekTRIMP = thisWeekTRIMP
            lastWeekMinutes = WeeklyPlanner.estimatedWeeklyMinutes(from: thisWeekRuns)
        }
        
        // Decide next week target using PRD adaptation rules:
        // - Undertrained or overreached -> overloadFactor = 1.0 (repeat week)
        // - Good progression (TRIMP within [1.0, 1.1] * lastWeekTRIMP) -> overloadFactor = 1.05
        // - Always respect +10% cap.
        let nextTarget = AdaptationEngine.nextWeekMinutes(
            lastWeekTRIMP: lastWeekTRIMP,
            thisWeekTRIMP: thisWeekTRIMP,
            lastWeekMinutes: lastWeekMinutes,
            runningFrequency: selectedDays.count
        )
        
        // Write the NEXT week (the current Monday window)
        let nextWeekStart = closingWeekStart.addingWeeks(1)
        let nextWeek = WeeklyPlanner.zone2Week(
            weekStart: nextWeekStart,
            selectedDays: selectedDays,
            frequency: max(selectedDays.count, 1),
            totalZ2Minutes: nextTarget
        )
        
        // Merge: lock < nextWeekStart, replace future of that week only
        let locked = existing.runs.filter { $0.date < nextWeekStart }
        let future = existing.runs.filter { $0.date >= nextWeekStart }
        // drop any sessions inside [nextWeekStart, nextWeekStart+7)
        let keptFuture = future.filter { $0.date >= nextWeekStart.addingDays(7) }
        
        let merged = (locked + nextWeek + keptFuture).sorted { $0.date < $1.date }
        return GeneratedPlan(plan: existing.plan, runs: merged)
    }
}

// MARK: - Private (original onboarding helpers kept for back-compat)

private extension PlanMapper {
    
    // Your original weekly template logic (still used for onboarding only)
    static func weekTemplate(for plan: Plan, frequency: Int) -> [RunTemplate] {
        func easy(_ min: Int, _ z: HRZone = .z2) -> RunTemplate {
            .init(name: "Easy Run", kind: .easy, focus: .base, targetDurationSec: min*60, targetDistanceKm: 5, targetHRZone: z, notes: reliableNotesEasyRun)
        }
        
        let reliableNotesEasyRun: String = """
        The main purpose of the easy run is not speed, but volume and consistency. By running slowly, you stimulate key physiological adaptations:

        • Capillarization: You grow more capillaries (tiny blood vessels) around your muscle fibers, improving oxygen and nutrient delivery, and waste removal.
        • Connective Tissue Strength: You safely strengthen your muscles, tendons, and ligaments to handle higher training loads later.
        """
        
        func long(_ min: Int) -> RunTemplate {
            .init(
                name: "Long Run",
                kind: .long,
                focus: .endurance,
                targetDurationSec: min*60,
                targetDistanceKm: 10,
                targetHRZone: .z2,
                notes: reliableNotesLongRun
            )
        }
        
        let reliableNotesLongRun: String = """
        The purpose of the Long Run is multi-faceted, extending beyond basic aerobic fitness:
        
        • Maximal Fat Oxidation: You maximize the training effect of using fat as fuel, building fat-burning efficiency that is critical for avoiding "hitting the wall" in a race.
        • Musculoskeletal Toughness: The prolonged, repetitive impact strengthens connective tissues (tendons, ligaments, bones) and muscles to resist fatigue and injury over race distance.
        """
        
        func tempo(_ min: Int) -> RunTemplate {
            .init(name: "Tempo Run", kind: .tempo, focus: .speed, targetDurationSec: min*60, targetHRZone: .z3, notes: "Sustained medium-hard effort (Zone 3). Improves lactate threshold and pace control.")
        }
        func intervals(_ min: Int) -> RunTemplate {
            .init(name: "Interval Run", kind: .intervals, focus: .speed, targetDurationSec: min*60, targetHRZone: .z4, notes: "Alternating bursts of high-intensity (Zone 4) and recovery. Builds VO₂ max and speed.")
        }
        func recovery(_ min: Int) -> RunTemplate {
            .init(name: "Recovery Jog", kind: .recovery, focus: .base, targetDurationSec: min*60, targetHRZone: .z1, notes: "Very light effort (Zone 1). Promotes circulation and muscle repair between hard days.")
        }
        func maf(_ min: Int) -> RunTemplate {
            .init(name: "MAF Training", kind: .maf, focus: .endurance, targetDurationSec: min*45, targetHRZone: .z2, notes: "In the initial stages of Maximum Aerobic Function (MAF) training, a runner must often significantly slow down their pace to stay within the target heart rate. The training is successful when, over time, the runner can maintain the same low heart rate while running at a faster pace. This indicates a more efficient aerobic system.")
        }
        
        switch plan {
        case .baseBuilder, .endurance:
            var t = [easy(30), easy(30), long(60), maf(45)]
            if frequency > t.count { t += Array(repeating: easy(25, .z1), count: frequency - t.count) }
            return t
        case .speed:
            var t = [easy(30), easy(30), long(60), tempo(60), maf(45)]
            if frequency > t.count { t += Array(repeating: easy(25, .z1), count: frequency - t.count) }
            return t
        case .halfMarathonPrep:
            var t = [tempo(25), intervals(30), easy(35), long(75), recovery(20)]
            if frequency > t.count { t += Array(repeating: easy(25, .z1), count: frequency - t.count) }
            return t
        }
    }
    
    static func makeSchedule(
        template: [RunTemplate],
        startDate: Date,
        selectedDays: Set<Int>,
        totalSessions: Int
    ) -> [ScheduledRun] {
        var result: [ScheduledRun] = []
        let cal = Calendar.current
        var date = startDate
        var i = 0
        
        while result.count < totalSessions {
            if selectedDays.contains(cal.component(.weekday, from: date)) {
                result.append(ScheduledRun(date: date, template: template[i % template.count]))
                i += 1
            }
            date = cal.date(byAdding: .day, value: 1, to: date)!
        }
        return result
    }
}

// MARK: - Week helpers

private func runs(in plan: GeneratedPlan, weekStart: Date) -> [ScheduledRun] {
    let weekEnd = weekStart.addingDays(7)
    return plan.runs.filter { $0.date >= weekStart && $0.date < weekEnd }
}

private func isLastRunOfWeekCompleted(plan: GeneratedPlan, weekStart: Date) -> Bool {
    let week = runs(in: plan, weekStart: weekStart)
    guard !week.isEmpty else { return false }
    // “last run of the week” means: the latest-dated run inside the week is completed
    guard let last = week.max(by: { $0.date < $1.date }) else { return false }
    return last.status == .completed
}

// MARK: - Date helpers

private extension Date {
    func mondayFloor() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 // Monday
        let weekday = cal.component(.weekday, from: self)
        let delta = (weekday == 1) ? -6 : (2 - weekday) // shift Sunday back 6, otherwise to Monday
        let start = cal.date(byAdding: .day, value: delta, to: self)!
        return cal.startOfDay(for: start)
    }
    func addingDays(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: n, to: self)!
    }
    func addingWeeks(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: 7*n, to: self)!
    }
}

