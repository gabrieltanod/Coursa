//
//  MetricsPreview.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct OverviewPageView: View {

    let distance: String = "2,67 KM"
    let bpm: Int = 125
    let currentPace: String = "7:28"
    let lapCount: Int = 2
    
    private let headerHeight: CGFloat = 100

    func formattedTime(time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d,%02d", minutes, seconds, milliseconds)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Spacer(minLength: headerHeight)
            
            Text(distance)
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.white)
            
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: String(bpm), unit: "BPM", color: "primary")
                
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(lapCount)")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color("secondary"))
                .cornerRadius(8)
            }
            
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: currentPace, unit: "/KM", color: "primary")
                MetricLabelView(topText: "CUR", bottomText: "PACE")
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
    OverviewPageView()
}
