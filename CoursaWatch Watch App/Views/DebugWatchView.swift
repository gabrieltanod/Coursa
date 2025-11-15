//
//  DebugWatchView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 16/11/25.
//

import SwiftUI
import Combine
import Foundation

struct DebugWatchView: View {
    @EnvironmentObject var workoutManager: WorkoutManager

    var body: some View {
        VStack(spacing: 16) {
            Button("Set fake run id") {
                // Replace with a real id from your plan if you have it,
                // for now just hardcode something and we’ll align it later.
                workoutManager.currentRunId = "DEBUG-RUN-ID"
            }

            Button("Send Fake Summary to iOS") {
                let summary = RunningSummary(
                    id: workoutManager.currentRunId ?? "DEBUG-RUN-ID",
                    totalTime: 1800,           // 30 mins
                    totalDistance: 5.0,        // 5 km
                    averageHeartRate: 140,
                    averagePace: 360           // 6:00 /km
                )
                workoutManager.sendSummaryToiOS(summary)
            }
        }
    }
}
