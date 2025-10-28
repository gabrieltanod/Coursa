//
//  PaceView.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct PaceView : View {
    
    private let headerHeight: CGFloat = 105
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer(minLength: headerHeight)
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: "7:30", unit: "/KM", color: "primary")
                MetricLabelView(topText: "CUR", bottomText: "HR")
            }
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: "7:30", unit: "/KM", color: "primary")
                MetricLabelView(topText: "AVG", bottomText: "HR")
            }
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: "7:30", unit: "/KM", color: "primary")
                MetricLabelView(topText: "AVG", bottomText: "PACE")
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
    PaceView()
}
