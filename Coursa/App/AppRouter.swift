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

    func goToCoreApp(with data: OnboardingData) {
        path.append(Route.coreApp(data))
        didOnboard = true
    }

    func goToPlan(with data: OnboardingData) {
        path.append(Route.plan(data))
        didOnboard = true
    }

    func goHome() {
        path.append(Route.home)
    }

    func reset() {
        path = NavigationPath()
        didOnboard = false
    }
}
