//
//  RunningSummaryView.swift
//  Coursa
//
//  Created by Zikar Nurizky on 10/11/25.
//

import SwiftUI

struct RunningSummaryView: View {
    let run: ScheduledRun?
    let summary: RunningSummary?
    
    var body: some View {
        ScrollView {
            VStack {
                if let run = run, let summary = summary {
                    // Display summary data with run and summary
                    RunningSummaryCard(run: run, summary: summary)
                    // Masukin value ke HR card yers
                    HeartRateCard(avgHR: Int(summary.averageHeartRate))
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color("black-450"))
                        )
                    
                    // Masukin value ke sini jg uers
                    PaceResultCard(
                        avgPace: formatPace(summary.averagePace),
                        maxPace: formatPace(summary.averagePace) // Using avg as max for now
                    )
                } else {
                    // No summary available - show placeholder
                    Text("No summary data available")
                        .foregroundColor(.gray)
                        .padding()
                }
                Spacer()
            }
            .padding(24)
        }
        .background(Color("black-500"))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }
    
    private func formatPace(_ paceInMinutesPerKm: Double) -> String {
        // paceInMinutesPerKm is in minutes per km
        // Convert to mm:ss format
        let totalSeconds = Int(paceInMinutesPerKm * 60)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

//#Preview {
//    RunningSummaryView()
//}
