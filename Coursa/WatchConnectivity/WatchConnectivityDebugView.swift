//
//  Untitled.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 14/11/25.
//

import SwiftUI

struct WatchConnectivityDebugView: View {
    @EnvironmentObject var syncService: SyncService
    @EnvironmentObject var planManager: PlanManager

    // Dummy plan for testing send action
    private let dummyPlan = RunningPlan(
        date: Date(),
        name: "Easy Run",
        kind: .maf,
        targetDistance: 3.0,
        targetHRZone: .z2,
        recPace: "7:30/KM"
    )

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // MARK: - Watch Connectivity Status
                VStack(spacing: 8) {
                    Text("📡 Watch Connectivity")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if syncService.isSessionActivated {
                        Text("Session Active")
                            .foregroundColor(.green)
                            .font(.headline)
                    } else {
                        Text("Activating Session...")
                            .foregroundColor(.orange)
                            .font(.headline)
                    }
                }
                
                Divider()
                
                // MARK: - Send Plan to Watch
                VStack(alignment: .leading, spacing: 10) {
                    Text("🏃 Send Running Plan")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name: \(dummyPlan.name)")
                        Text("Distance: \(dummyPlan.targetDistance ?? 0, specifier: "%.1f") km")
                        Text("Zone: \(dummyPlan.targetHRZone?.rawValue ?? 0)")
                        Text("Recommended Pace: \(dummyPlan.recPace ?? "-")")
                        Text("Date: \(dummyPlan.date.formatted(date: .abbreviated, time: .shortened))")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                    Button(action: { planManager.sendPlanToWatchOS(dummyPlan) }) {
                        Text("Send Plan to Watch")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
                
                Divider()
                
                // MARK: - Received Summary
                VStack(alignment: .leading, spacing: 10) {
                    Text("📈 Received Summary")
                        .font(.headline)
                    
                    if let summary = syncService.summary {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("✅ New Summary Received")
                                .foregroundColor(.green)
                                .font(.subheadline)
                            
                            Group {
                                Text("Total Time: \(formatTime(summary.totalTime))")
                                Text("Distance: \(summary.totalDistance, specifier: "%.2f") km")
                                Text("Average HR: \(summary.averageHeartRate, specifier: "%.0f") BPM")
                                Text("Average Pace: \(summary.averagePace, specifier: "%.2f") min/km")
                            }
                            .font(.subheadline)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                    } else {
                        Text("Waiting for summary data from Apple Watch...")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding(.top, 6)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.05))
                .cornerRadius(12)
            }
            .padding()
        }
        .onAppear {
            print("📱 iOS App started — WatchConnectivity active: \(syncService.isSessionActivated)")
        }
    }

    // MARK: - Helper
    private func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
}
