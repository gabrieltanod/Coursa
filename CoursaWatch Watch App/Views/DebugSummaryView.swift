//
//  DebugSummaryView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 16/11/25.
//

import SwiftUI

struct DebugSummaryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    // Paste one of the real IDs from the iOS debug log here
    private let testRunId: String = "C83317F6-76BD-4B39-97BA-4AA314FE71B3"

    var body: some View {
        VStack(spacing: 12) {
            Text("Debug Summary")
                .font(.headline)

            Button("Use test run id") {
                workoutManager.currentRunId = testRunId
                print("[Watch DEBUG] currentRunId set to \(testRunId)")
            }

            Button("Send Fake Summary to iOS") {
                let summary = RunningSummary(
                    id: testRunId,
                    totalTime: 1800,          // 30 min
                    totalDistance: 5.0,       // 5 km
                    averageHeartRate: 140,
                    averagePace: 360          // 6:00 / km
                )

                print("[Watch DEBUG] Sending fake summary: \(summary)")
                workoutManager.sendSummaryToiOS(summary)
            }
        }
        .padding()
    }
}
