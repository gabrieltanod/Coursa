//
//  MetricsNoteView.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 26/10/25.
//

import SwiftUI

struct MetricLabelView: View {
    var topText: String = "0"
    var bottomText: String = "0"
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(topText)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
            
            Text(bottomText)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}


#Preview {
    MetricLabelView(topText: "CUR", bottomText: "HR")
}
