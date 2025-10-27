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
                HomeView()
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .plan(let data):
                            PlanView(vm: PlanViewModel(data: data))
                        case .home:
                            HomeView()
                        }
                    }
            } else {
                OnboardingFlowView { finishedData in
                    router.goToPlan(with: finishedData)
                }
            }
        }
        .task {
            if let existing = OnboardingStore.load() {
                router.didOnboard = true
                router.path.append(Route.plan(existing))
            }
        }
    }
}
