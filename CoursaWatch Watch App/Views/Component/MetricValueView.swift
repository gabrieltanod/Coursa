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
                .font(.helveticaNeue(size: 30))
                .foregroundColor(Color(color))
            Text(unit)
                .font(.helveticaNeue(size: 14))
                .foregroundColor(Color(color))
        }
    }
}

#Preview {
    MetricValueView(value: "333", unit: "BPM", color: "primary")
}
