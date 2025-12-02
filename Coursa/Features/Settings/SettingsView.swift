//
//  SettingsView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 03/11/25.
//

import SwiftUI
import HealthKit

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    
    // Keep these if they are needed for other child views or if we want to keep them available
    // But since we moved logic to VM, we might not need them here directly if VM handles everything.
    // However, `router` and `planSession` are passed to VM.
    // `syncService` and `planManager` were unused in the View logic previously (only declared).
    // We can keep them if we want to be safe, or remove if unused.
    // Let's keep them as EnvironmentObjects to ensure they are available if child views need them implicitly,
    // though explicit injection is better.
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject var planSession: PlanSessionStore
    @EnvironmentObject private var syncService: SyncService
    @EnvironmentObject private var planManager: PlanManager
    
    @AppStorage("selectedTab") private var selectedTab: Int = 0
    
    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    /// The main content view for the settings screen.
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
                        viewModel.handleHealthKitTap()
                    }

                    SettingsCard(
                        icon: Image(systemName: "list.bullet.rectangle"),
                        iconBackground: Color.white.opacity(0.12),
                        title: "Privacy Notes",
                        subtitle: "See how your data is utilized."
                    ) {
                        viewModel.openPrivacyNotes()
                    }
                }

                Spacer()

                #if DEBUG
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color("white-500").opacity(0.6))

                    Button(role: .destructive) {
                        viewModel.resetApp()
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
                                .fill(Color.red.opacity(0.15))
                        )
                        .foregroundColor(.red)
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
                                viewModel.simulateRun(paceSecPerKm: 420, zone2Percentage: 0.80)
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
                                viewModel.simulateRun(paceSecPerKm: 540, zone2Percentage: 0.75)
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
                                viewModel.simulateRun(paceSecPerKm: 450, zone2Percentage: 0.40)
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
                }
                #endif
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
        }
        .preferredColorScheme(.dark)
        .sheet(item: $viewModel.activeSheet) { sheet in
            switch sheet {
            case .privacy:
                PrivacyNotesView()
                    .presentationDetents([.medium, .large])
            case .healthConnected:
                HealthKitConnectedView()
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(router: AppRouter(), planSession: PlanSessionStore()))
        .environmentObject(AppRouter())
        .environmentObject(SyncService.shared)
        .environmentObject(PlanManager())
        .preferredColorScheme(.dark)
}
