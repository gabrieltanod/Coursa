//
//  MetricValueView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 26/10/25.
//

import SwiftUI

struct MetricValueView: View {
    var value: String = "0"
    var unit: String = "0"
    var color: String
    
    var body: some View {
        HStack (alignment: .lastTextBaseline) {
            Text(value)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(Color(color))
            Text(unit)
                .font(. system(size: 14, weight: .semibold))
                .foregroundColor(Color(color))
        }
    }
}

#Preview {
    MetricValueView(value: "333", unit: "BPM", color: "primary")
}
