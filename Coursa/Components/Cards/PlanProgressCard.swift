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
        "\(Int((progress * 100).rounded()))% of goal"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Kickoff banner + title
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    Image("PlanRocket")
                    //                        .font(.system(size: 20, weight: .semibold))
                    //                        .foregroundStyle(Color("green-500"))

                    Text(progressMessage)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color("green-500"))
                }
                .padding(.bottom, 14)

                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color("white-500"))
                    .lineLimit(1)

            }

            // Progress label + percent pill
            HStack(alignment: .center) {
                Text("Your Progress")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color("white-500").opacity(0.85))

                Spacer(minLength: 12)

                Text(percentText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("white-500"))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule().fill(Color("white-500").opacity(0.18))
                    )
            }

            // Progress bar
            VStack(spacing: 6) {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color("white-500").opacity(0.22))
                        .frame(height: 6)
                    GeometryReader { geo in
                        Capsule()
                            .fill(
                                Color("green-500")
                            )
                            .frame(
                                width: max(0, min(progress, 1))
                                    * geo.size.width,
                                height: 6
                            )
                            .animation(
                                .easeInOut(duration: 0.35),
                                value: progress
                            )
                    }
                    .frame(height: 6)
                }
            }

            // Bottom row
            //            HStack {
            //                Text("Week  \(weekNow) / \(weekTotal)")
            //                    .font(.system(size: 18, weight: .regular))
            //                    .foregroundStyle(Color("white-500"))
            //
            //                Spacer()
            //
            //                Text("Distance  ")
            //                    .font(.system(size: 17, weight: .regular))
            //                    .foregroundStyle(Color("white-500")) +
            //                Text("\(completedKm.clean) / \(targetKm.clean) KM")
            //                    .font(.system(size: 17, weight: .bold))
            //                    .foregroundStyle(Color("white-500"))
            //            }
        }
        .frame(width: .infinity, height: 100)
        .padding(16)
        .background(
            ZStack {
                // Full-card gradient background from Figma

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("black-450"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .inset(by: 0.5)
                            .stroke(
                                Color(red: 0.3, green: 0.29, blue: 0.3),
                                lineWidth: 1
                            )

                    )
                Image("PlanProgressCardBG")
                    .resizable()
                    .scaledToFill()
                    //                    .frame(width: 392, height: 149)
                    .clipped()
                // Dark tint card on top of the gradient, but still behind content
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        )
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
        title: "Endurance",
        progress: 0.25,
//        weekNow: 1,
//        weekTotal: 4,
        completedKm: 15,
        targetKm: 60
    )
}
