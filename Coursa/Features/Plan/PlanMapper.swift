//
//  PlanMapper.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

import Foundation

//struct DayWorkout: Identifiable, Codable {
//    let id = UUID()
//    let date: Date
//    let title: String
//    let description: String
//}

// Replace DayWorkout + old GeneratedPlan with this:
struct GeneratedPlan: Codable {
    let plan: Plan
    var runs: [ScheduledRun]
}

enum PlanMapper {
    static func generatePlan(from data: OnboardingData) -> GeneratedPlan? {
        guard
            let selectedPlan = data.selectedPlan ?? data.recommendedPlan,
            !data.trainingPrefs.selectedDays.isEmpty
        else { return nil }

        let frequency = data.trainingPrefs.daysPerWeek
        let durationWeeks = selectedPlan == .halfMarathonPrep ? 10 : 8
        let totalSessions = frequency * durationWeeks
        let weekTemplate = weekTemplate(for: selectedPlan, frequency: frequency) // [RunTemplate]

        let runs = makeSchedule(
            template: weekTemplate,
            startDate: data.startDate,
            selectedDays: data.trainingPrefs.selectedDays,
            totalSessions: totalSessions
        )

        return GeneratedPlan(plan: selectedPlan, runs: runs)
    }

    // Return real templates instead of strings
    private static func weekTemplate(for plan: Plan, frequency: Int) -> [RunTemplate] {
        func easy(_ min: Int, _ z: HRZone = .z2) -> RunTemplate {
            .init(name: "Easy Run", kind: .easy, focus: .base, targetDurationSec: min*60, targetDistanceKm: 5 ,targetHRZone: z, notes: "Low-intensity aerobic run (Zone 2). Builds base endurance and active recovery capacity.")
        }
        func long(_ min: Int) -> RunTemplate {
            .init(name: "Long Run", kind: .long, focus: .endurance, targetDurationSec: min*60, targetDistanceKm: 10, targetHRZone: .z2, notes: "Extended steady-pace session (Zone 2). Strengthens endurance, mental resilience, and fat adaptation.")
        }
        func tempo(_ min: Int, notes: String? = nil) -> RunTemplate {
            .init(name: "Tempo Run", kind: .tempo, focus: .speed, targetDurationSec: min*60, targetHRZone: .z3, notes: "Sustained medium-hard effort (Zone 3). Improves lactate threshold and pace control.")
        }
        func intervals(_ min: Int, notes: String? = nil) -> RunTemplate {
            .init(name: "Interval Run", kind: .intervals, focus: .speed, targetDurationSec: min*60, targetHRZone: .z4, notes: "Alternating bursts of high-intensity (Zone 4) and recovery. Builds VO₂ max and speed.")
        }
        func recovery(_ min: Int) -> RunTemplate {
            .init(name: "Recovery Jog", kind: .recovery, focus: .base, targetDurationSec: min*60, targetHRZone: .z1, notes: "Very light effort (Zone 1). Promotes circulation and muscle repair between hard days.")
        }
        func maf(_ min: Int) -> RunTemplate {
            .init(name: "MAF Training", kind: .maf, focus: .endurance, targetDurationSec: min*45, targetHRZone: .z2, notes: "Steady Zone 2 run near aerobic threshold. Trains efficiency while minimizing fatigue.")
        }

        switch plan {
        case .baseBuilder:
            var t = [easy(30), easy(30), long(60), maf(45)]
            if frequency > t.count { t += Array(repeating: easy(25, .z1), count: frequency - t.count) }
            return t
        case .endurance:
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

    private static func makeSchedule(
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

extension PlanMapper {
    /// Regenerate future runs when schedule (or plan) changes,
    /// while preserving all past runs and their statuses.
    static func regeneratePlan(
        existing: GeneratedPlan,
        newPlan: Plan? = nil,
        newSelectedDays: Set<Int>,
        today: Date = Date()
    ) -> GeneratedPlan {
        let cal = Calendar.current
        let todayStart = cal.startOfDay(for: today)

        // 1. Lock all runs before today (keep completed/skipped/etc.)
        let lockedRuns = existing.runs.filter { $0.date < todayStart }

        // Use updated plan if given, otherwise keep existing
        let plan = newPlan ?? existing.plan

        // 2. Work out frequency + duration based on new schedule
        let frequency = max(newSelectedDays.count, 1)
        let durationWeeks = plan == .halfMarathonPrep ? 10 : 8
        let totalSessions = frequency * durationWeeks

        // If user already has more past runs than new plan length, just keep them.
        guard lockedRuns.count < totalSessions else {
            return GeneratedPlan(plan: plan, runs: lockedRuns.sorted { $0.date < $1.date })
        }

        // 3. Templates for this plan/frequency
        let weekTemplate = weekTemplate(for: plan, frequency: frequency)

        // 4. How many future sessions we still need
        let remainingSessions = totalSessions - lockedRuns.count

        // 5. Start generating from today with new selectedDays
        let futureRuns = makeSchedule(
            template: weekTemplate,
            startDate: todayStart,
            selectedDays: newSelectedDays,
            totalSessions: remainingSessions
        )

        // 6. Stitch back together
        let allRuns = (lockedRuns + futureRuns).sorted { $0.date < $1.date }

        return GeneratedPlan(plan: plan, runs: allRuns)
    }
}
