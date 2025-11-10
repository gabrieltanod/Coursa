//
//  WatchConnectDisplay.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 05/11/25.
//

import Foundation
import SwiftUI


// Dummy UI buat test watchconnectivity

struct WatchConnectDisplay: View {
    
    @EnvironmentObject var syncService: SyncService

    var body: some View {
        VStack(spacing: 20) {
            Text("Watch Connect")
                .font(.largeTitle)
            
            // Display session status
            if syncService.isSessionActivated {
                Text("Status: Session Active")
                    .foregroundColor(.green)
                    .font(.headline)
            } else {
                Text("Status: Activating Session...")
                    .foregroundColor(.orange)
                    .font(.headline)
            }
            
            // Check if data summary has been received
            if let summary = syncService.summary {
                
                Text("New Summary Received!")
                    .foregroundColor(.green)
                    .font(.headline)
                
                // Display Total Time from Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total Time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(formatTime(summary.totalTime))")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Distance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(summary.totalDistance, specifier: "%.2f") km")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("Average HR")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(summary.averageHeartRate, specifier: "%.0f") BPM")
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("Average Pace")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(summary.averagePace, specifier: "%.2f") min/km")
                        .font(.system(size: 20, weight: .semibold))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
            } else {
                Text("Waiting for data from Apple Watch...")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            print("iOS App Started. SyncService activated.")
        }
    }
    
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
