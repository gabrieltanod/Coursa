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
                    
                    Button {
                        loadPaceRecommendationDebug()
                    } label: {
                        HStack {
                            Image(systemName: "gauge.with.dots.needle.67percent")
                                .font(.system(size: 18, weight: .semibold))
                            Text("Test Pace Recommendation")
                                .font(.system(size: 15, weight: .medium))
                            Spacer()
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.green.opacity(0.15))
                        )
                        .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                    
                    // Simulation buttons for testing pace updates
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Test Pace Updates")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color("white-500").opacity(0.5))
                        
                        HStack(spacing: 8) {
                            // Fast run
                            Button {
                                planSession.simulateCompletedRun(paceSecPerKm: 420, zone2Percentage: 0.80)
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "hare.fill")
                                        .font(.system(size: 16))
                                    Text("Fast Run")
                                        .font(.system(size: 11, weight: .medium))
                                    Text("7:00/km")
                                        .font(.system(size: 10))
                                        .opacity(0.7)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue.opacity(0.15))
                                )
                                .foregroundColor(.blue)
                            }
                            
                            // Slow run
                            Button {
                                planSession.simulateCompletedRun(paceSecPerKm: 540, zone2Percentage: 0.75)
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "tortoise.fill")
                                        .font(.system(size: 16))
                                    Text("Slow Run")
                                        .font(.system(size: 11, weight: .medium))
                                    Text("9:00/km")
                                        .font(.system(size: 10))
                                        .opacity(0.7)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.orange.opacity(0.15))
                                )
                                .foregroundColor(.orange)
                            }
                            
                            // Poor Z2
                            Button {
                                planSession.simulateCompletedRun(paceSecPerKm: 450, zone2Percentage: 0.40)
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 16))
                                    Text("Poor Z2")
                                        .font(.system(size: 11, weight: .medium))
                                    Text("40%")
                                        .font(.system(size: 10))
                                        .opacity(0.7)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.red.opacity(0.15))
                                )
                                .foregroundColor(.red)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
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
    
    func loadPaceRecommendationDebug() {
        print("🏃 Loading Pace Recommendation Debug Data...")
        
        // Load the debug data
        planSession.loadPaceRecommendationDebugData()
        
        // Switch to the Plan tab to see the runs
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedTab = 0  // Plan tab (HomeView)
        }
        
        print("✅ Navigate to 'Today's Easy Run' detail page to see the recommended pace!")
        print("📊 Expected: ~8:10/km (based on historical 8:00/km average + 10 sec buffer)")
    }
}
