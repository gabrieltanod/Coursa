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
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardGradient)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: overlaySymbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 140)
                        .foregroundStyle(.white.opacity(0.15))
                        .padding(12)
                }
                .clipped()
            
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        
                        .strokeBorder(.white.opacity(0.5), lineWidth: 1.5)
                )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.95))

                Text(run.title)
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.white)

                HStack {
                    badge(run.subtitle)
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
    }

    private var formattedDate: String {
        run.date.formatted(.dateTime
            .weekday(.abbreviated)   // "Sat"
            .month(.wide)            // "October"
            .day(.defaultDigits))    // "25"
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
        return .init(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var overlaySymbol: String {
        let t = run.title.lowercased()
        if t.contains("maf") { return "heart.fill" }
        if t.contains("easy") { return "shoeprints.fill" }
        if t.contains("long") { return "road.lanes" }
        return "figure.run" // fallback
    }

    @ViewBuilder
    private func badge(_ text: String) -> some View {
        Text(text)
            .font(.caption)
//            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(.white)
//            .background(.white.opacity(0.15), in: Capsule())
    }
}
