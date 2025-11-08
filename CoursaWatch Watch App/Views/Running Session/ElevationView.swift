//
//  PaceView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct ElevationView : View {
    
    private let headerHeight: CGFloat = 105
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer(minLength: headerHeight)
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: String(format: "%.0f", workoutManager.elevation), unit: "M", color: "primary")
                MetricLabelView(topText: "", bottomText: "ELV")
            }
            
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: String(format: "%.0f", workoutManager.elevationGain), unit: "M", color: "primary")
                MetricLabelView(topText: "ELV", bottomText: "GAIN")
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ignoresSafeArea()
        .background(Color("app"))
    }
}
