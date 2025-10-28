//
//  HeartRateView.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct SummaryPaceElevationView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            Text("Average Pace:")
                .font(.system(size: 14, weight: .semibold))
            
            MetricValueView(value: "7:28", unit: "/KM", color: "secondary")
                
            Text("Elevation Gain:")
                .font(.system(size: 14, weight: .semibold))
            
            MetricValueView(value: "7", unit: "M", color: "secondary")
            
            Spacer()
        }
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("app"))
    }
}


#Preview {
    SummaryPaceElevationView()
}
