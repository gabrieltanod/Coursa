//
//  MetricCard.swift
//  Coursa
//
//  Created by Gabriel Tanod on 15/11/25.
//

import SwiftUI

struct MetricBlob<Content: View>: View {
    @ViewBuilder let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color(red: 0.13, green: 0.12, blue: 0.12))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .inset(by: 0.5)
                    .stroke(
                        Color(red: 0.3, green: 0.29, blue: 0.3),
                        lineWidth: 1
                    )
            )
    }
}

struct WeeklyProgressCard: View {
    let title: String
    let progressText: String  // e.g. "15 / 25 KM"

    var body: some View {
        MetricBlob {
            HStack(alignment: .center) {
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color("white-500"))

                Spacer()

                Text(progressText)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color("green-500"))
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.top, 20)
    }
}

struct MetricDetailCard: View {
    let title: String
    let primaryValue: String  // e.g. "8:25/km"
    let secondaryValue: String  // e.g. "8:45/km"
    let footer: String  // e.g. "Average Pace Last Week and Two Week Ago"

    var body: some View {
        MetricBlob {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color("white-500"))
                    .lineLimit(2, reservesSpace: true)

                Text(primaryValue)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(Color("green-500"))

                Text(secondaryValue)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color("white-700"))

                Text(footer)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color("white-700"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(width: 180, height: 172, alignment: .topLeading)
    }
}

#Preview("Metric Cards") {
    ZStack {
        Color("black-500").ignoresSafeArea()

        VStack(spacing: 20) {
            WeeklyProgressCard(
                title: "Weekly Progress",
                progressText: "15 / 25 KM"
            )

            HStack(spacing: 20) {
                MetricDetailCard(
                    title: "Average Pace",
                    primaryValue: "8:25/km",
                    secondaryValue: "8:45/km",
                    footer: "Average Pace Last Week and Two Week Ago"
                )

                MetricDetailCard(
                    title: "Duration in HR Zone 2",
                    primaryValue: "1:43:37",
                    secondaryValue: "1:26:15",
                    footer: "Your Duration in Zone 2 Last Week and Two Week Ago"
                )
            }
        }
    }
}
