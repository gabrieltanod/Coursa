import SwiftUI

struct OnboardingFlowView: View {
    @StateObject private var vm = OnboardingViewModel()
    let onFinished: (OnboardingData) -> Void
    @State private var showPlanReady = false
    @State private var showGenerating = false
    @State private var generatingProgress: Double = 0
    
    @ViewBuilder
    private var stepContent: some View {
        switch vm.step {
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
        case .chooseStartDate:
            ChooseStartDateStepView(onFinish: { date in
                vm.setStartDate(date)
                OnboardingStore.save(vm.data)
                // Show generating overlay for ~2 seconds
                generatingProgress = 0
                showGenerating = true
                
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: 2.0)) {
                        generatingProgress = 1
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    UserDefaults.standard.set(true, forKey: "shouldShowPlanGeneratedSheet")
                    withAnimation {
                        onFinished(vm.data)
                    }
                }
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
            
            if showGenerating {
                GeneratingOverlay(progress: generatingProgress)
                    .transition(.opacity)
                    .ignoresSafeArea()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if vm.canGoBack && !showGenerating {
                    Button(action: vm.back) {
                        Image(systemName: "chevron.backward")
                    }
                    .buttonStyle(.plain)  // keeps native look in nav bars
                } else {
                    EmptyView()
                }
            }
            ToolbarItem(placement: .principal) {
                if vm.step.usesProgress && !showGenerating {
                    CarouselIndicator(currentIndex: vm.index)
                        .frame(maxWidth: .infinity)
                } else {
                    EmptyView()
                }
            }
        }
    }
}

private struct GeneratingOverlay: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            // Frosted backdrop
            Rectangle()
                .fill(.ultraThinMaterial)
                .background(Color.black.opacity(0.35))
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                Text("Generating Your Running Plan")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                Text("Greatness is just a moment away…")
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(.white)
                    .padding(.bottom, 6)
                
                // Progress bar
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.25)) // softer, cleaner background
                        .frame(width: 220, height: 2)    // <- thinner height
                    Capsule()
                        .fill(
                            Color("green-500")
                        )
                        .frame(width: 220 * max(0, min(progress, 1)), height: 2) // match thin height
                }
            }
            .padding(20)
        }
    }
}
