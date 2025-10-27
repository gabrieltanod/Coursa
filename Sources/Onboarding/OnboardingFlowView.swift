import SwiftUI

struct OnboardingFlowView: View {
    @StateObject private var vm = OnboardingViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Main content based on current step
                Group {
                    switch vm.step {
                    case .goals:
                        GoalsStepView(onGoalSelected: { goal in
                            vm.setGoal(goal)
                            vm.next()
                        })
                    case .personalInfo:
                        PersonalInfoStepView(onContinue: { personalInfo in
                            vm.setPersonalInfo(personalInfo)
                            vm.next()
                        })
                    case .daysPerWeek:
                        DaysPerWeekStepView(onContinue: { days in
                            vm.setDaysPerWeek(days)
                            vm.next()
                        })
                    case .whichDays:
                        WhichDaysStepView(onContinue: { days in
                            vm.setSelectedDays(days)
                            vm.next()
                        })
                    case .personalBest:
                        PersonalBestStepView(onContinue: { distanceKm, durationText in
                            vm.setPersonalBest(distanceKm: distanceKm, durationText: durationText)
                            vm.updateRecommendedPlan()
                            vm.next()
                        })
                    case .recommendedPlan:
                        RecommendedPlanStepView(
                            recommendedPlan: vm.data.recommendedPlan ?? .baseBuilder,
                            onContinue: { vm.next() },
                            onChooseDifferent: { vm.next() }
                        )
                    case .choosePlan:
                        ChoosePlanStepView(onContinue: { plan in
                            vm.setSelectedPlan(plan)
                            vm.next()
                        })
                    case .chooseStartDate:
                        ChooseStartDateStepView(onFinish: { date in
                            vm.setStartDate(date)
                            vm.next()
                        })
                    case .home:
                        HomeView()
                    }
                }
                .navigationTitle(vm.step.title)
                .navigationBarTitleDisplayMode(.large)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if vm.canGoBack && !vm.isLastStep {
                        Button("Back") {
                            vm.back()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingFlowView()
}

