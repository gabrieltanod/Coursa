//
//  PaceView.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct ElevationView : View {
    
    private let headerHeight: CGFloat = 105
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer(minLength: headerHeight)
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: "7", unit: "M", color: "primary")
                MetricLabelView(topText: "CUR", bottomText: "ELV")
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
    ElevationView()
}
