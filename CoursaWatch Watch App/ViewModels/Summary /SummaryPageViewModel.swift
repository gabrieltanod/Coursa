//
//  SummaryViewModel.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 30/10/25.
//

import Foundation
import SwiftUI
import Combine

class SummaryPageViewModel: ObservableObject {
    
    private let summary: WorkoutSummary
    
    init(summary: WorkoutSummary) {
        self.summary = summary
    }
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
    
    
    var formattedAverageHR: String {
        return String(format: "%.0f", summary.averageHeartRate)
    }
    
    var formattedTotalDistance: String {
        return String(format: "%.2f", summary.totalDistance)
    }
    
    var formattedAveragePace: String {
        return formatPace(paceMinutes: summary.averagePace)
    }
    
    var formattedElevationGain: String {
        return String(format: "%.0f", summary.elevationGain)
    }
    
    func formatPace(paceMinutes: Double) -> String {
        let minutes = Int(paceMinutes)
        let secondsDecimal = paceMinutes.truncatingRemainder(dividingBy: 1)
        let seconds = Int(secondsDecimal * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private var maxTimeInZone: Double {
        return summary.zoneDuration.values.max() ?? 0
    }
    
    private func formatTime(seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let remainingSeconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
        } else {
            return String(format: "%d:%02d", minutes, remainingSeconds)
        }
    }
    
    var zoneChartData: [(zone: Int, timeString: String, percentage: Double, isMax: Bool)] {
        var chartData: [(zone: Int, timeString: String, percentage: Double, isMax: Bool)] = []
        
        let totalTime = summary.totalTime
        let maxTime = self.maxTimeInZone
        
        for zone in 1...5 {
            let timeInSeconds = summary.zoneDuration[zone] ?? 0.0
            let formattedTimeString = formatTime(seconds: timeInSeconds)
            
            var percentage = 0.0
            if totalTime > 0 {
                percentage = (timeInSeconds / totalTime) * 100
            }
            
            let isMax = (timeInSeconds == maxTime && timeInSeconds > 0)
            
            chartData.append(
                (zone: zone, timeString: formattedTimeString, percentage: percentage, isMax: isMax)
            )
        }
        return chartData
    }
    
    
}
