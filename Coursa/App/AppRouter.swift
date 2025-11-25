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

    func reset(hard: Bool = true, planSession: PlanSessionStore? = nil) {
        // Reset navigation + onboarding flag
        path = NavigationPath()
        didOnboard = false

        guard hard else { return }

        // --- CLEAR ONBOARDING DATA ---
        OnboardingStore.clear()
        UserDefaults.standard.removeObject(forKey: "hasSeenWelcome")
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")

        // --- CLEAR GENERATED PLAN (persisted) ---
        UserDefaults.standard.removeObject(forKey: "coursa.generatedPlan")

        // --- CLEAR IN-MEMORY PLAN STATE (PlanSessionStore) ---
        if let session = planSession {
            session.generatedPlan = nil
        }

        // --- CLEAR SELECTED TAB ---
        UserDefaults.standard.removeObject(forKey: "selectedTab")
        
        // --- CLEAR PLAN GENERATED SHEET FLAG ---
        UserDefaults.standard.removeObject(forKey: "showPlanGeneratedSheet")
        
        // --- CLEAR ANY OTHER FLAGS ---
        UserDefaults.standard.removeObject(forKey: "coursa.autoSkipApplied")
        
        print("✅ [DEBUG] App reset complete - all data cleared")
    }
}
