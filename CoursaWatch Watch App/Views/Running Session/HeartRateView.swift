//
//  HeartRateView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct HeartRateView: View {
    
    private let headerHeight: CGFloat = 105
    @EnvironmentObject var workoutManager: WorkoutManager
    private var currentZone: Int {
        let hr = workoutManager.heartRate
        let maxHeartRate: Double = 195.0
        guard maxHeartRate > 0 else { return 0 }
        let hrPercentage = (hr / maxHeartRate) * 100.0
        
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
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Spacer(minLength: headerHeight)
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { zone in
                    HRZoneIndicatorView(
                        zoneNumber: zone,
                        isActive: zone == currentZone
                    )
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentZone)
            
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: String(format: "%.0f", workoutManager.heartRate), unit: "BPM", color: "primary")
                MetricLabelView(topText: "CUR", bottomText: "HR")
            }
            
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: String(format: "%.0f", workoutManager.averageHeartRate), unit: "BPM", color: "primary")
                MetricLabelView(topText: "AVG", bottomText: "HR")
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ignoresSafeArea()
        .background(Color("app"))
    }
}


#Preview {
    HeartRateView()
}
