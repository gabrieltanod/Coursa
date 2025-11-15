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
    
    // WatchConnectivity + Plan manager from environment
    @EnvironmentObject private var syncService: SyncService
    @EnvironmentObject private var planManager: PlanManager
    
    // Local sheets for actions
    private enum ActiveSheet: Identifiable { case watch, privacy
        var id: String { String(self.hashValue) }
    }
    @State private var activeSheet: ActiveSheet?

    var body: some View {
        ZStack {
            Color("black-500").ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("Settings")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(Color("white-500"))
                    .padding(.top, 8)

                VStack(spacing: 16) {
                    SettingsCard(
                        icon: Image(systemName: "applewatch"),
                        iconBackground: Color.white.opacity(0.12),
                        title: "Connect Apple Watch",
                        subtitle: "Apple Watch can upload directly to Coursa."
                    ) {
                        // Activate/connect WCSession and show status sheet
                        activeSheet = .watch
                    }

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

                #if DEBUG
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color("white-500").opacity(0.6))

                    Button(role: .destructive) {
                        router.reset(hard: true)
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
                }
                #endif
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
        .preferredColorScheme(.dark)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .watch:
                // Simple connectivity status and tools
                ConnectAppleWatch()
                    .environmentObject(syncService)
                    .environmentObject(planManager)
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
}
