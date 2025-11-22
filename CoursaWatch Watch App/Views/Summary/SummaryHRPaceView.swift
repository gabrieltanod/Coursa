//
//  SummaryHRView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct SummaryHRPaceView: View {
    @ObservedObject var viewModel: SummaryPageViewModel
    
    private var currentZone: Int {
        let hr = Double(viewModel.formattedAverageHR) ?? 0
        
        // Use maxHR from synced plan if available, otherwise fallback
        let maxHeartRate: Double = viewModel.currentPlan?.userMaxHR ?? 195.0
        
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
        VStack(alignment: .leading, spacing: 4){
            Text("Average HR")
                .font(.helveticaNeue(size: 16))
                .foregroundColor(Color("primary"))
                .padding(.top, 8)
            
            HStack {
                MetricValueView(value: viewModel.formattedAverageHR, unit: "",color: "primary")
                    .bold()
                
                HRZoneBadgeView(
                    zoneNumber: currentZone,
                    bgColor: currentZoneColors.bg,
                    textColor: currentZoneColors.text
                )
            }
            
            Text("Average Pace")
                .font(.helveticaNeue(size: 16))
                .foregroundColor(Color("primary"))
            
            MetricValueView(value: viewModel.formattedAveragePace, unit: "/KM", color: "primary")
                .bold()
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color("app"))
    }
}
