//
//  PlanMapper.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

import Foundation

struct DayWorkout: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let title: String
    let description: String
}

struct GeneratedPlan: Codable {
    let plan: Plan
    let workouts: [DayWorkout]
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
        let weekTemplate = weekTemplate(for: selectedPlan, frequency: frequency)

        // generate calendar days
        let workouts = makeSchedule(
            template: weekTemplate,
            startDate: data.startDate,
            selectedDays: data.trainingPrefs.selectedDays,
            totalSessions: totalSessions
        )

        return GeneratedPlan(plan: selectedPlan, workouts: workouts)
    }

    private static func weekTemplate(for plan: Plan, frequency: Int) -> [String] {
        switch plan {
        case .baseBuilder:
            return ["Easy Run", "Rest", "Easy Run", "Long Run"]
        case .fiveKTimeTrial:
            return ["Tempo Run", "Interval Run", "Easy Run", "Long Run"]
        case .tenKImprover:
            return ["Intervals", "Tempo Run", "Easy Run", "Long Run"]
        case .halfMarathonPrep:
            return ["Tempo Run", "Intervals", "Easy Run", "Long Run", "Recovery Jog"]
        }
    }

    private static func makeSchedule(
        template: [String],
        startDate: Date,
        selectedDays: Set<Int>,
        totalSessions: Int
    ) -> [DayWorkout] {
        var result: [DayWorkout] = []
        let cal = Calendar.current
        var date = startDate
        var i = 0

        while result.count < totalSessions {
            let weekday = cal.component(.weekday, from: date)
            if selectedDays.contains(weekday) {
                let name = template[i % template.count]
                result.append(DayWorkout(
                    date: date,
                    title: name,
                    description: "Week \(result.count / template.count + 1): \(name)"
                ))
                i += 1
            }
            date = cal.date(byAdding: .day, value: 1, to: date)!
        }
        return result
    }
}
