//
//  PaceView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct PaceView : View {
    
    private let headerHeight: CGFloat = 105
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer(minLength: headerHeight)
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: "7:30", unit: "/KM", color: "primary")
                MetricLabelView(topText: "REC", bottomText: "PACE", isPaceView: true)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color("secondary"))
                    .cornerRadius(8)
            }
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: (formatPace(paceMinutes: workoutManager.pace)), unit: "/KM", color: "primary")
                MetricLabelView(topText: "CUR", bottomText: "PACE")
            }
            
            Spacer()
            
            Text("KEEP STEADY")
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(Color("accent"))
                .cornerRadius(8)
            
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
