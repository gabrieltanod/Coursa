import SwiftUI

struct OnboardingFlowView: View {
    @StateObject private var vm = OnboardingViewModel()
    let onFinished: (OnboardingData) -> Void

    @ViewBuilder
    private var stepContent: some View {
        switch vm.step {
        case .goals:
            GoalsStepView(onGoalSelected: { goal in
                vm.setGoal(goal)
                vm.next()
            })
            .padding(.horizontal, 24)
            .background(Color("black-500"))
        case .personalInfo:
            PersonalInfoStepView(onContinue: { personalInfo in
                vm.setPersonalInfo(personalInfo)
                vm.next()
            })
            .padding(.horizontal, 24)
            .background(Color("black-500"))
        case .whichDays:
            WhichDaysStepView(onContinue: { days in
                vm.setSelectedDays(days)
                vm.setDaysPerWeek(days.count)
                vm.next()
            })
            .padding(.horizontal, 24)
            .background(Color("black-500"))
        case .personalBest:
            PersonalBestStepView(onContinue: { distanceKm, durationText in
                vm.setPersonalBest(
                    distanceKm: distanceKm,
                    durationText: durationText
                )
                vm.updateRecommendedPlan()
                vm.next()
            })
            .padding(.horizontal, 24)
            .background(Color("black-500"))
        // If you intend to keep choosePlan in the future, re-enable it here.
        // case .choosePlan:
        //     ChoosePlanStepView(onContinue: { plan in
        //         vm.setSelectedPlan(plan)
        //         vm.next()
        //     })
        case .chooseStartDate:
            ChooseStartDateStepView(onFinish: { date in
                vm.setStartDate(date)
                OnboardingStore.save(vm.data)
                onFinished(vm.data)
            })
            .padding(.horizontal, 24)
            .background(Color("black-500"))
        }
    }

    var body: some View {
        ZStack {
            // Main content based on current step
            stepContent
                .navigationBarTitleDisplayMode(.large)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if vm.canGoBack {
                    Button(action: vm.back) {
                        Image(systemName: "chevron.backward")
                    }
                    .buttonStyle(.plain)  // keeps native look in nav bars
                } else {
                    EmptyView()
                }
            }
            ToolbarItem(placement: .principal) {
                if vm.step.usesProgress {
                    CarouselIndicator(currentIndex: vm.index)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
