//
//  PlanProgressCard.swift
//  Coursa
//
//  Created by Gabriel Tanod on 07/11/25.
//

import SwiftUI

struct PlanProgressCard: View {
    let title: String
    let progress: Double  // 0...1 based on sessions completed
    //    let weekNow: Int                  // 1-based (e.g. 1)
    //    let weekTotal: Int
    let completedKm: Double
    let targetKm: Double
    
    private var progressMessage: String {
        if progress == 0 {
            return "Kick Off Your Run"
        } else if progress < 0.5 {
            return "Keep It Going!"
        } else {
            return "Almost There"
        }
    }
    
    var percentText: String {
        "\(Int((progress * 100).rounded()))% of your goal"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 20) {
                // Left: circular progress ring with rocket icon
                ZStack {
                    // Base ring
                    Circle()
                        .stroke(Color("white-500").opacity(0.25), lineWidth: 7)
                    
                    // Progress arc
                    Circle()
                        .trim(from: 0, to: CGFloat(max(0, min(progress, 1))))
                        .stroke(
                            Color("green-500"),
                            style: StrokeStyle(lineWidth: 7, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    // Rocket image in the center
                    Image("PlanRocketWhite")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 33, height: 33)
                }
                .frame(width: 75, height: 75)
                
                // Right: text stack
                VStack(alignment: .leading, spacing: 4) {
                    Text(progressMessage)
                        .font(.custom("Helvetica Neue", size: 16, relativeTo: .body))                        .foregroundStyle(Color("green-500"))
                    
                    Text(title)
                        .font(.custom("Helvetica Neue", size: 20, relativeTo: .title3))
                        .fontWeight(.medium)
                        .foregroundStyle(Color("white-500"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    Text(percentText)
                        .font(.custom("Helvetica Neue", size: 13, relativeTo: .footnote))
                        .foregroundStyle(Color("white-500").opacity(0.7))
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color("black-700"))
        .cornerRadius(20)
    }
}

extension Double {
    fileprivate var clean: String {
        truncatingRemainder(dividingBy: 1) == 0
        ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
}

#Preview {
    PlanProgressCard(
        title: "Endurance Training",
        progress: 0.25,
        //        weekNow: 1,
        //        weekTotal: 4,
        completedKm: 15,
        targetKm: 60
    )
}
