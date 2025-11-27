//
//  RunningSessionCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 27/10/25.
//

import SwiftUI

// A simple cell that matches your lofi (title + specs)
struct RunningSessionCard: View {
    let run: ScheduledRun

    private var cardBackgroundName: String {
        let t = run.title.lowercased()
        if t.contains("maf") { return "MAFRunningCardBG" }
        if t.contains("easy") { return "EasyRunningCardBG" }
        if t.contains("long") { return "LongRunningCardBG" }
        return "MAFRunningCardBG"
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.clear)
                .overlay(alignment: .bottomTrailing) {
                    Image(cardBackgroundName)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                }
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .inset(by: 0.5)
                        .stroke(
                            Color(red: 0.3, green: 0.29, blue: 0.3),
                            lineWidth: 1
                        )

                )

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(formattedDate)
                        .font(.custom("Helvetica Neue", size: 13, relativeTo: .footnote))
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.95))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    Text(run.title)
                        .font(.custom("Helvetica Neue", size: 20, relativeTo: .title3))
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    HStack {
                        badge(run.subtitle)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.custom("Helvetica Neue", size: 16, relativeTo: .body))
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: 392, minHeight: 109/*, maxHeight: 110*/)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .inset(by: 0.5)
                .stroke(Color(red: 0.3, green: 0.29, blue: 0.3), lineWidth: 1)

        )
    }

    private var formattedDate: String {
        run.date.formatted(
            .dateTime
                .weekday(.abbreviated)  // "Sat"
                .month(.wide)  // "October"
                .day(.defaultDigits)
        )  // "25"
    }

    //    private var zoneText: String { "HR Zone 2" }

    private var cardGradient: LinearGradient {
        let colors: [Color]
        switch run.title.lowercased() {
        case let t where t.contains("maf"):
            colors = [.purple, .blue]
        case let t where t.contains("easy"):
            colors = [.blue, .teal]
        case let t where t.contains("long"):
            colors = [.purple, .indigo]
        default:
            colors = [.indigo, .blue]
        }
        return .init(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var overlaySymbol: String {
        let t = run.title.lowercased()
        if t.contains("maf") { return "heart.fill" }
        if t.contains("easy") { return "shoeprints.fill" }
        if t.contains("long") { return "road.lanes" }
        return "figure.run"  // fallback
    }

    @ViewBuilder
    private func badge(_ text: String) -> some View {
        Text(text)
            .font(.custom("Helvetica Neue", size: 16, relativeTo: .body))
            .foregroundStyle(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
    }
}

#Preview("RunningSessionCard – Samples") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack(spacing: 16) {
            RunningSessionCard(
                run: ScheduledRun(
                    date: Date(),
                    template: RunTemplate(
                        name: "MAF Training",
                        kind: .easy,
                        focus: .endurance,
                        targetDurationSec: 1800,
                        targetDistanceKm: 5.0,
                        targetHRZone: .z2,
                        notes: "Keep HR in Zone 2"
                    )
                )
            )
            RunningSessionCard(
                run: ScheduledRun(
                    date: Calendar.current.date(
                        byAdding: .day,
                        value: 2,
                        to: Date()
                    ) ?? Date(),
                    template: RunTemplate(
                        name: "Long Run",
                        kind: .long,
                        focus: .endurance,
                        targetDurationSec: 2400,
                        targetDistanceKm: 6.0,
                        targetHRZone: .z3,
                        notes: "Sustain comfortably hard"
                    )
                )
            )
            RunningSessionCard(
                run: ScheduledRun(
                    date: Calendar.current.date(
                        byAdding: .day,
                        value: 2,
                        to: Date()
                    ) ?? Date(),
                    template: RunTemplate(
                        name: "Easy Run",
                        kind: .easy,
                        focus: .endurance,
                        targetDurationSec: 2400,
                        targetDistanceKm: 6.0,
                        targetHRZone: .z3,
                        notes: "Sustain comfortably hard"
                    )
                )
            )
        }
    }
}
