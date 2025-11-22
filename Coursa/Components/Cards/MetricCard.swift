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
            .background(Color("black-700"))
            .cornerRadius(20)
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

enum ComparisonTrend {
    case better
    case worse
    case same
}

struct MetricDetailCard: View {
    let title: String
    let primaryValue: String  // e.g. "8:25/km"
    let secondaryValue: String  // e.g. "8:45/km"
    let footer: String  // e.g. "Average Pace Last Week and Two Week Ago"
    let showInfoButton: Bool
    let onInfoTapped: (() -> Void)?
    let comparisonTrend: ComparisonTrend?
    
    init(
        title: String,
        primaryValue: String,
        secondaryValue: String,
        footer: String,
        showInfoButton: Bool = false,
        onInfoTapped: (() -> Void)? = nil,
        comparisonTrend: ComparisonTrend? = nil
    ) {
        self.title = title
        self.primaryValue = primaryValue
        self.secondaryValue = secondaryValue
        self.footer = footer
        self.showInfoButton = showInfoButton
        self.onInfoTapped = onInfoTapped
        self.comparisonTrend = comparisonTrend
    }

    var body: some View {
        MetricBlob {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color("white-700"))
                        .lineLimit(2, reservesSpace: true)
                    
                    Spacer()
                    
                    if showInfoButton {
                        Button(action: {
                            onInfoTapped?()
                        }) {
                            Image(systemName: "info.circle")
                                .font(.system(size: 13))
                                .foregroundStyle(Color("white-700"))
                        }
                        .padding(.bottom, 22)
                    }
                }

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(primaryValue)
                        .font(.system(size: 30, weight: .medium))
                        .foregroundStyle(Color("white-500"))
                    
                    if let trend = comparisonTrend, trend != .same {
                        Image(systemName: trend == .better ? "arrow.up" : "arrow.down")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(trend == .better ? Color("green-500") : Color.red)
                    }
                }
            }
        }
        .frame(width: .infinity, height: 172, alignment: .topLeading)
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
                    primaryValue: "7:15/km",
                    secondaryValue: "7:45/km",
                    footer: "Average Pace Last Week and Two Week Ago",
                    comparisonTrend: .better  // Improved pace (faster)
                )

                MetricDetailCard(
                    title: "Aerobic Time",
                    primaryValue: "1:12:30",
                    secondaryValue: "1:43:37",
                    footer: "Your Duration in Zone 2 Last Week and Two Week Ago",
                    showInfoButton: true,
                    onInfoTapped: { print("Info tapped") },
                    comparisonTrend: .worse  // Regressed aerobic time (less time)
                )
            }
        }
    }
}
