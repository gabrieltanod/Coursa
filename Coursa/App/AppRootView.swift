//
//  AppRootView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            if router.didOnboard {
                if let existing = OnboardingStore.load() {
                    CoreTabView(onboardingData: existing)
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .coreApp(let data):
                                CoreTabView(onboardingData: data)
                            case .plan(let data):
                                PlanView(vm: PlanViewModel(data: data))
                            case .home:
                                HomeView()
                            }
                        }
                } else {
                    Text("Failed to load onboarding data")
                        .foregroundColor(.secondary)
                }
            } else {
                OnboardingFlowView { finishedData in
                    OnboardingStore.save(finishedData)
                    router.goToCoreApp(with: finishedData)
                }
            }
        }
        .task {
            if let existing = OnboardingStore.load() {
                router.didOnboard = true
                //                router.path.append(Route.coreApp(existing))
            }
        }
    }
}
