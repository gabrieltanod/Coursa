//
//  HeaderTimerView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI
import Combine

struct HeaderTimerView: View {
    private let headerHeight: CGFloat = 100
    @Binding var timeElapsed: Double
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Spacer()
            Text(formattedTime(time: timeElapsed))
                .font(.helveticaNeue(size: 38, weight: .bold))
                .foregroundColor(Color("secondary"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity)
        .frame(height: headerHeight)
        .background(Color("app"))
        
    }
    
    func formattedTime(time: Double) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    struct PreviewWrapper2: View {
        @State private var timeElapsed: Double = 0.0
        var body: some View {
            HeaderTimerView(timeElapsed: $timeElapsed)
        }
    }
    return PreviewWrapper2()
}
