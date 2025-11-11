//
//  AppRouter.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

import Combine
import SwiftUI

@MainActor
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var didOnboard = false

    func goToCoreApp() {
        path = NavigationPath()
        didOnboard = true
    }

    func goToPlan(with data: OnboardingData) {
        path.append(Route.plan(data))
        didOnboard = true
    }

    func goHome() {
        path.append(Route.home)
    }

    func reset(hard: Bool = true) {
        path = NavigationPath()
        didOnboard = false

        guard hard else { return }

        // Clear anything that re-triggers onboarding skip
        OnboardingStore.clear()  // implement this to remove stored data
        UserDefaults.standard.removeObject(forKey: "hasSeenWelcome")
    }
}
