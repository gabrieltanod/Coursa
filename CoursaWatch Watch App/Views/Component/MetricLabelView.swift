//
//  MetricLabelView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 26/10/25.
//

import SwiftUI

struct MetricLabelView: View {
    var topText: String = "0"
    var bottomText: String = "0"
    var isPaceView: Bool = false
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(topText)
            Text(bottomText)
        }
        .font(.system(size: 10, weight: .semibold))
        .foregroundColor(Color(isPaceView ? "app" : "primary"))
    }
}

#Preview {
    MetricLabelView(topText: "CUR", bottomText: "HR")
}
