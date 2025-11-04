//
//  SummaryViewModel.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 30/10/25.
//

import Foundation
import SwiftUI

class SummaryViewModel: ObservableObject {
    
    private let summary: WorkoutSummary
    
    init(summary: WorkoutSummary) {
        self.summary = summary
    }
    
    // 1. Waktu Total (Detik -> HH:MM:SS)
    var formattedTotalTime: String {
        let totalSeconds = Int(summary.totalTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    // 2. Average HR (Double -> String)
    var formattedAverageHR: String {
        return String(format: "%.0f BPM", summary.averageHeartRate)
    }
    
    // 3. Average Pace (Double -> M:SS/KM)
    var formattedAveragePace: String {
        // Gunakan fungsi formatPace() yang sudah kita buat sebelumnya
        return formatPace(paceMinutes: summary.averagePace) + "/KM"
    }

    // 4. Elevation Gain (Double -> String)
    var formattedElevationGain: String {
        return String(format: "%.0f M", summary.elevationGain)
    }
    
    // 5. Data Zone (Diproses untuk Bar Chart)
    var zoneChartData: [(zone: Int, time: Double, percentage: Double)] {
        guard summary.totalTime > 0 else { return [] }
        
        // Konversi waktu absolut menjadi persentase dari total waktu
        let totalTime = summary.totalTime
        
        return summary.zoneDuration.map { (zone, time) in
            let percentage = (time / totalTime) * 100
            return (zone: zone, time: time, percentage: percentage)
        }
        .sorted { $0.zone < $1.zone } // Urutkan 1 sampai 5
    }
}
