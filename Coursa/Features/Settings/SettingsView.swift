//
//  SettingsView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 03/11/25.
//

import SwiftUI
import HealthKit

struct SettingsView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject var planSession: PlanSessionStore
    // WatchConnectivity + Plan manager from environment
    @EnvironmentObject private var syncService: SyncService
    @EnvironmentObject private var planManager: PlanManager
    @AppStorage("selectedTab") private var selectedTab: Int = 0
    
    // Local sheets for actions
    private enum ActiveSheet: Identifiable { case privacy
        var id: String { String(self.hashValue) }
    }
    @State private var activeSheet: ActiveSheet?

    /// The main content view for the settings screen.
    ///
    /// This computed property returns a SwiftUI view hierarchy that displays the settings interface
    /// with a dark theme and various configuration options for the user.
    ///
    /// ## Layout Structure
    /// - **Background**: Full-screen dark background using "black-500" color
    /// - **Header**: "Settings" title with large, semibold typography
    /// - **Settings Cards**: Three interactive cards for different settings categories:
    ///   - Apple Watch connectivity with pairing functionality
    ///   - Apple Health integration with HealthKit authorization
    ///   - Privacy policy access through a modal sheet
    /// - **Debug Section**: Development-only reset functionality for testing
    ///
    /// ## Interactive Elements
    /// - Tappable settings cards that trigger different actions (sheets, authorization requests)
    /// - Sheet presentations for Apple Watch setup and privacy notes
    /// - Debug reset button (DEBUG builds only) for clearing app state
    ///
    /// ## Data Flow
    /// - Uses environment objects for navigation (AppRouter), sync services, and plan management
    /// - Manages local state for sheet presentations through `ActiveSheet` enumeration
    /// - Integrates with HealthKit for health data authorization
    ///
    /// ## Accessibility
    /// - Supports dark color scheme preference
    /// - Uses semantic colors that adapt to system settings
    /// - Provides clear visual hierarchy with appropriate font weights and sizes
    ///
    /// - Returns: A SwiftUI `View` containing the complete settings interface
    var body: some View {
        ZStack {
            Color("black-500").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("Settings")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color("white-500"))
                    .padding(.top, 8)

                VStack(spacing: 16) {
                    SettingsCard(
                        icon: Image(systemName: "heart.fill"),
                        iconBackground: Color.white.opacity(0.12),
                        title: "Apple Health",
                        subtitle: "Connect with Apple's Health app."
                    ) {
                        requestHealthKitAuthorization()
                    }

                    SettingsCard(
                        icon: Image(systemName: "list.bullet.rectangle"),
                        iconBackground: Color.white.opacity(0.12),
                        title: "Privacy Notes",
                        subtitle: "See how your data is utilized."
                    ) {
                        activeSheet = .privacy
                    }
                }

                Spacer()

//                #if DEBUG
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color("white-500").opacity(0.6))

                    Button(role: .destructive) {
                        router.reset(hard: true, planSession: planSession)
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Reset App (Debug)")
                                .font(.system(size: 15, weight: .medium))
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.04))
                        )
                    }
                    .buttonStyle(.plain)
                    
//                    Button {
//                        setupScenario2()
//                    } label: {
//                        HStack {
//                            Image(systemName: "play.circle.fill")
//                                .font(.system(size: 18, weight: .semibold))
//                            Text("Scenario 2")
//                                .font(.system(size: 15, weight: .medium))
//                            Spacer()
//                        }
//                        .padding(12)
//                        .background(
//                            RoundedRectangle(cornerRadius: 14, style: .continuous)
//                                .fill(Color.white.opacity(0.04))
//                        )
//                    }
//                    .buttonStyle(.plain)
                }
//                #endif
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .preferredColorScheme(.dark)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .privacy:
                PrivacyNotesView()
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppRouter())
        .environmentObject(SyncService())
        .environmentObject(PlanManager())
        .preferredColorScheme(.dark)
}

// MARK: - Helpers
private extension SettingsView {
    func requestHealthKitAuthorization() {
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
        }
    }
    
    func setupScenario2() {
        // 1. Reset the router to prepare for navigation
        router.path = NavigationPath()
        
        // 2. Set up mock onboarding data
        let mockData = OnboardingStore.mock()
        OnboardingStore.save(mockData)
        
        // 3. Mark onboarding as completed
        router.didOnboard = true
        UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // 4. Generate a plan with runs for today and next 2 days, plus some history
//        planSession.loadScenario2Data()
        
        // 5. Bootstrap the plan session to ensure everything is properly set up
        planSession.bootstrapIfNeeded(using: mockData)
        
        // 6. Switch to the Plan tab (HomeView) - Tab 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedTab = 0  // Plan tab
        }
    }
}
