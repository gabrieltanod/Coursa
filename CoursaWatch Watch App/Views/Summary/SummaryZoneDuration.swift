//
//  SummaryZoneDuration.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 18/11/25.
//

import SwiftUI

struct WorkoutSummaryView: View {
    @ObservedObject var workoutManager: WorkoutManager

    var body: some View {
        VStack(spacing: 16) {
            Text("Workout Summary")
                .font(.headline)
            
            // Zone Durations
            ForEach(workoutManager.zoneDurationTracker.keys.sorted(), id: \.self) { zone in
                HStack {
                    Text("Zone \(zone)")
                    Spacer()
                    Text("\(Int(workoutManager.zoneDurationTracker[zone] ?? 0)) sec")
                }
            }
        }
        .padding()
    }
}
