//
//  HeaderTimerView.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI
internal import Combine

struct HeaderTimerView: View {
    
    let laps: Int = 3
    private let headerHeight: CGFloat = 100
    @Binding var timeElapsed: Double
    @State private var currentTimeString = "00:00"
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .stroke(Color.yellow, lineWidth: 2)
                        .frame(width: 26, height: 26)
                    Text("\(laps)")
                        .foregroundColor(.white)
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .padding(.leading, 10)
                .offset(y: 2)
                
                Spacer()
            }
            .padding(.bottom, 18)
            
            
            Text(formattedTime(time: timeElapsed))
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(Color("secondary"))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 18)
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity)
        .frame(height: headerHeight)
        .background(Color("app"))
        
    }
    
    func formattedTime(time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d,%02d", minutes, seconds, milliseconds)
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
