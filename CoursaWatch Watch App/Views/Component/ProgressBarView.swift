//
//  ProgressBarView.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 17/11/25.
//

import SwiftUI

struct ProgressBarView: View {
    var distanceText: Double
    var isHalfway: Bool = false
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 12)
                .foregroundColor(Color.gray.opacity(0.8))
            
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Color("secondary"),
                    style: StrokeStyle(
                        lineWidth: 12,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 2.0), value: animatedProgress)
            
            VStack(spacing: 2) {
                Text(
                    isHalfway
                    ? "\(String(format: "%.1f", distanceText / 2)) KM" // masukin durasi disini yeah
                    : "\(String(format: "%.1f", distanceText)) KM"
                )
                    .font(.helveticaNeue(size: 30, weight: .bold))
                    .foregroundColor(Color("secondary"))
                
                Text(
                    isHalfway
                    ? "Halfway there!"
                    : "Done!"
                )
                    .font(.helveticaNeue(size: 17, weight: .semibold))
                    .foregroundColor(Color("secondary"))
            }
        }
        .padding(30)
        .onAppear {
            animatedProgress = max(0, min(1, isHalfway ? 0.5 : 1.0))
        }
        .background(Color("app"))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ProgressBarView(
            distanceText: 6.0,
            isHalfway: false
        )
        .frame(width: 220, height: 220)
    }
}

