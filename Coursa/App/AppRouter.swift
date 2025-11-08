//
//  AppRouter.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

import SwiftUI
import Combine

@MainActor
final class AppRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var didOnboard = false

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
