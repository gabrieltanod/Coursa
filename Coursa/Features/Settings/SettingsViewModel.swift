//
//  SettingsViewModel.swift
//  Coursa
//
//  Created by Gabriel Tanod on 03/12/25.
//

import Foundation
import SwiftUI
import HealthKit
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var activeSheet: ActiveSheet?
    
    // MARK: - Dependencies
    private let router: AppRouter
    private let planSession: PlanSessionStore
    // These might not be strictly needed in VM if only used for environment injection in View, 
    // but if we move logic that uses them, we need them here.
    // Checking SettingsView, SyncService and PlanManager are just EnvironmentObjects, 
    // seemingly not used in the logic I saw in step 23 (only router and planSession were used in debug logic).
    // Wait, let me re-verify usage in SettingsView from step 23.
    
    // MARK: - Init
    init(router: AppRouter, planSession: PlanSessionStore) {
        self.router = router
        self.planSession = planSession
    }
    
    // MARK: - Enums
    enum ActiveSheet: Identifiable {
        case privacy
        case healthConnected
        
        var id: String { String(describing: self) }
    }
    
    // MARK: - Actions
    
    func handleHealthKitTap() {
        // Check if HealthKit is already authorized
        let isAuth = HealthKitManager.shared.isAuthorized()
        print("HealthKit isAuthorized: \(isAuth)")
        
        if isAuth {
            // Show the connected view with instructions to disable via Settings
            print("Showing HealthKit connected sheet")
            // In VM, we can just set the published property. 
            // The View will react.
            self.activeSheet = .healthConnected
        } else {
            print("Requesting HealthKit authorization")
            // Request authorization
            requestHealthKitAuthorization()
        }
    }
    
    func openPrivacyNotes() {
        activeSheet = .privacy
    }
    
    private func requestHealthKitAuthorization() {
        // HealthKit is optional on device; guard capability first
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let store = HKHealthStore()
        // Minimal read/write types as placeholders; adjust as needed
        let toShare: Set = [HKObjectType.workoutType()]
        let toRead: Set = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        ]
        store.requestAuthorization(toShare: toShare, read: toRead) { success, error in
            if let error = error { print("HealthKit auth error: \(error)") }
            print("HealthKit auth success: \(success)")
            // We might want to update UI or state here if needed, but for now just print.
        }
    }
    
    // MARK: - Debug Actions
    
    func resetApp() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        router.reset(hard: true, planSession: planSession)
    }
    
    func simulateRun(paceSecPerKm: Int, zone2Percentage: Double) {
//        #if DEBUG
        planSession.simulateCompletedRun(paceSecPerKm: paceSecPerKm, zone2Percentage: zone2Percentage)
//        #endif
    }
}
