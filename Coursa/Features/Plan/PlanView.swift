//
//  PlanView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

import SwiftUI
import Combine

struct PlanView: View {
    @StateObject var vm: PlanViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Goal picker
                Picker("Goal", selection: Binding(
                    get: { vm.data.goal ?? .runConsistently },
                    set: { vm.data.goal = $0 }
                )) {
                    ForEach(Goal.allCases) { goal in
                        Text(goal.rawValue).tag(goal)
                    }
                }
                .pickerStyle(.segmented)

                // Days per week stepper
                Stepper("Days per week: \(vm.data.trainingPrefs.daysPerWeek)",
                        value: $vm.data.trainingPrefs.daysPerWeek,
                        in: 2...6)

                // Generate recommendation
                Button("Recommend Plan") {
                    vm.computeRecommendation()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)

                if let plan = vm.recommendedPlan {
                    Text("Recommended: \(plan.rawValue)")
                        .font(.headline)
                        .padding(.bottom, 5)

                    Button("Generate Workouts") {
                        vm.data.selectedPlan = plan
                        vm.data.trainingPrefs.selectedDays = [2,4,6] // Tue, Thu, Sat dummy
                        vm.generatePlan()
                    }
                    .buttonStyle(.bordered)
                }

                // Render generated plan
                if let generated = vm.generatedPlan {
                    List(generated.workouts) { workout in
                        VStack(alignment: .leading) {
                            Text(workout.title).font(.headline)
                            Text(workout.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(workout.date.formatted(date: .complete, time: .omitted))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                } else {
                    Spacer()
                    Text("No plan yet").foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Plan Generator")
        }
    }
}

#Preview {
    let dummyData = OnboardingData(
        goal: .improve5K,
        personalInfo: PersonalInfo(age: 21, gender: "Male", weightKg: 70, heightCm: 172),
        trainingPrefs: TrainingPrefs(daysPerWeek: 2, selectedDays: [2,4]),
        personalBest: PersonalBest(distanceKm: 5.0, durationSeconds: 1500),
        recommendedPlan: .fiveKTimeTrial,
        selectedPlan: .fiveKTimeTrial,
        startDate: .now
    )
    return NavigationStack {
        PlanView(vm: PlanViewModel(data: dummyData))
    }
}
