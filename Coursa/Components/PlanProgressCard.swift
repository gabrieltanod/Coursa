//
//  PlanProgressCard.swift
//  Coursa
//
//  Created by Gabriel Tanod on 07/11/25.
//

import SwiftUI

struct PlanProgressCard: View {
    let title: String
    let progress: Double              // 0...1 based on sessions completed
    let weekNow: Int                  // 1-based (e.g. 1)
    let weekTotal: Int
    let completedKm: Double
    let targetKm: Double

    var percentText: String {
        "\(Int((progress * 100).rounded()))% of goal"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title + percent pill
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color("white-500"))
                    .lineLimit(1)

                Spacer(minLength: 12)

                Text(percentText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color("white-500"))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule().fill(Color("white-500").opacity(0.15))
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
                                LinearGradient(
                                    colors: [Color("green-500"), .white],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, min(progress, 1)) * geo.size.width, height: 6)
                            .animation(.easeInOut(duration: 0.35), value: progress)
                    }
                    .frame(height: 6)
                }
            }

            // Bottom row
            HStack {
                Text("Week  \(weekNow) / \(weekTotal)")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Color("white-500"))

                Spacer()

                Text("Distance  ")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Color("white-500")) +
                Text("\(completedKm.clean) / \(targetKm.clean) KM")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Color("white-500"))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color("black-450"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color("white-500").opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 10, y: 6)
    }
}

private extension Double {
    var clean: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
}
