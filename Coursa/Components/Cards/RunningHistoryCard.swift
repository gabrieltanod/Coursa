//
//  RunningHistoryCard.swift
//  Coursa
//
//  Created by Gabriel Tanod on 15/11/25.
//

import SwiftUI

/// Card used for *completed* / *skipped* runs in history.
struct RunningHistoryCard: View {
    let run: ScheduledRun
    /// When true, the card appears visually de-emphasized to represent a skipped run.
    let isSkipped: Bool

    init(run: ScheduledRun, isSkipped: Bool = false) {
        self.run = run
        self.isSkipped = isSkipped
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .inset(by: 0.5)
                        .stroke(
                            Color(red: 0.3, green: 0.29, blue: 0.3),
                            lineWidth: 1
                        )
                )

            HStack(spacing: 16) {
                // Left icon
                Image(systemName: "figure.run")
                    .font(.system(size: 36, weight: .semibold))
//                    .foregroundStyle(.white.opacity(isSkipped ? 0.5 : 0.9))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.9), Color.gray.opacity(0.7),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Main content
                VStack(alignment: .leading, spacing: 6) {
                    Text(formattedDate)
                        .font(.custom("Helvetica Neue", size: 13, relativeTo: .footnote))
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.72))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(run.title)
                        .font(.custom("Helvetica Neue", size: 20, relativeTo: .title3))
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(isSkipped ? 0.7 : 1))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    HStack(spacing: 6) {
                        if let primaryMetricText {
                            Text(primaryMetricText)
                                .font(.custom("Helvetica Neue", size: 14, relativeTo: .footnote))
                                .fontWeight(.medium)
                        }
                        
                        Image(systemName: "circle.fill")
                            .font(.system(size: 3))
                            .foregroundStyle(.white.opacity(0.5))

                        Text(averageHRText)
                            .font(.custom("Helvetica Neue", size: 14, relativeTo: .footnote))
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.white.opacity(isSkipped ? 0.6 : 0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                }

                Spacer()

                RunHistoryIndicator(isSkipped: isSkipped)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .shadow(color: .black.opacity(0.22), radius: 8, y: 4)
        .opacity(isSkipped ? 0.7 : 1)
    }

    // MARK: - Formatting helpers

    private var formattedDate: String {
        run.date.formatted(
            .dateTime
                .month(.wide)
                .day(.defaultDigits)
        )
    }

    /// Primary metric on the second line:
    /// - Long runs: distance in km
    /// - Others: duration in minutes
    private var primaryMetricText: String? {
        switch run.template.kind {
        case .long:
            return formattedDistanceText
        default:
            return formattedDurationText
        }
    }

    private var formattedDistanceText: String? {
        guard let distance = run.template.targetDistanceKm,
            distance > 0
        else { return nil }

        let number = NSNumber(value: distance)
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.locale = .current

        let value =
            formatter.string(from: number)
            ?? String(format: "%.2f", distance)

        return "\(value) km"
    }

    private var formattedDurationText: String? {
        guard let durationSec = run.template.targetDurationSec else {
            return nil
        }
        let minutes = Int(durationSec / 60)
        guard minutes > 0 else { return nil }
        return "\(minutes) min"
    }

    private var averageHRText: String {
        if let hr = run.actual.avgHR {
            return "Avg HR \(hr) bpm"
        } else {
            return "Avg HR —"
        }
    }
}

private struct RunHistoryIndicator: View {
    let isSkipped: Bool

    var body: some View {
        ZStack(alignment: .trailing) {

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(
                    isSkipped
                        ? Color.white.opacity(0.7)
                        : Color.white
                )
        }
        .frame(width: 44, height: 24, alignment: .trailing)
    }
}

#Preview("RunningHistoryCard – Samples") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 16) {
            RunningHistoryCard(
                run: ScheduledRun(
                    date: Date(),
                    template: RunTemplate(
                        name: "MAF Training",
                        kind: .easy,
                        focus: .endurance,
                        targetDurationSec: 40 * 60,
                        targetDistanceKm: 5.0,
                        targetHRZone: .z2,
                        notes: "Keep HR in Zone 2"
                    )
                )
            )

            RunningHistoryCard(
                run: ScheduledRun(
                    date: Date(),
                    template: RunTemplate(
                        name: "Long Run",
                        kind: .long,
                        focus: .endurance,
                        targetDurationSec: 60 * 60,
                        targetDistanceKm: 10.03,
                        targetHRZone: .z2,
                        notes: "Comfortable long effort"
                    )
                )
            )

            RunningHistoryCard(
                run: ScheduledRun(
                    date: Date(),
                    template: RunTemplate(
                        name: "Easy Run",
                        kind: .easy,
                        focus: .endurance,
                        targetDurationSec: 30 * 60,
                        targetDistanceKm: 5.0,
                        targetHRZone: .z1,
                        notes: "Recovery jog"
                    )
                ),
                isSkipped: true
            )
        }
        .padding()
    }
}
