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

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardGradient)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: overlaySymbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundStyle(.white.opacity(0.15))
                        .padding(-10)
//                        .allowsHitTesting(false)
                }
                .clipped()

                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)

                        .strokeBorder(Color("black-400").opacity(1), lineWidth: 1.5)
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(formattedDate)
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(.white.opacity(0.95))

                Text(run.title)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)

                HStack {
                    badge(run.subtitle)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, minHeight: 110, maxHeight: 110)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
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
            .font(.caption)
            .foregroundStyle(.white)
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
                        name: "Tempo Run",
                        kind: .tempo,
                        focus: .speed,
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
