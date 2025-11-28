//
//  MetricsPreview.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct OverviewPageView: View {
    private let headerHeight: CGFloat = 100
    @EnvironmentObject var workoutManager: WorkoutManager
    
    private var currentZone: Int {
        let hr = workoutManager.heartRate
        
        let maxHeartRate = workoutManager.userMaxHeartRate
        
        guard maxHeartRate.isFinite && maxHeartRate > 0,
              hr.isFinite && hr >= 0 else { return 0 }
        
        let hrPercentage = max(0.0, min(100.0, (hr / maxHeartRate) * 100.0))
        
        if hrPercentage < 60 {         // Zone 1: < 60%
            return 1
        } else if hrPercentage < 70 {  // Zone 2: 60% - 69.9%
            return 2
        } else if hrPercentage < 80 {  // Zone 3: 70% - 79.9%
            return 3
        } else if hrPercentage < 90 {  // Zone 4: 80% - 89.9%
            return 4
        } else {                       // Zone 5: >= 90%
            return 5
        }
    }
    
    private var currentZoneColors: (bg: String, text: String) {
        let bgColor: String
        let textColor: String
        
        if currentZone == 1 {
            bgColor = "accent"
            textColor = "primary"
        } else if currentZone == 2 {
            bgColor = "secondary"
            textColor = "app"
        } else if currentZone == 3 {
            bgColor = "accentSecondary"
            textColor = "primary"
        } else {
            bgColor = "destructive"
            textColor = "primary"
        }
        
        return (bg: bgColor, text: textColor)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Spacer(minLength: headerHeight)
            
            Text(String(format: "%.2f KM", workoutManager.distance))
                .font(.helveticaNeue(size: 30))
                .foregroundColor(Color("primary"))
            
            HStack{
                Text(String(format: "%.0f", workoutManager.heartRate))
                    .font(.helveticaNeue(size: 30))
                    .foregroundColor(Color("primary"))
                
                HRZoneBadgeView(
                    zoneNumber: currentZone,
                    bgColor: currentZoneColors.bg,
                    textColor: currentZoneColors.text
                )
            }
            
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: (formatPace(paceMinutes: workoutManager.pace)), unit: "/KM", color: "primary")
                MetricLabelView(topText: "CUR", bottomText: "PACE")
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ignoresSafeArea()
        .background(Color("app"))
    }
    
    func formatPace(paceMinutes: Double) -> String {
        let minutes = Int(paceMinutes)
        let secondsDecimal = paceMinutes.truncatingRemainder(dividingBy: 1)
        let seconds = Int(secondsDecimal * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
}

