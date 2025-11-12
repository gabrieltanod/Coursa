//
//  PlanDetailView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 28/10/25.
//

import SwiftUI

struct PlanDetailView: View {
    let run: ScheduledRun
    @Environment(\.dismiss) private var dismiss
    @State private var isRunning = false
    @State private var didComplete = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color("black-500").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header image + overlay + text
                    ZStack(alignment: .bottom) {
                        Image("CoursaImages/Running_Easy")
                            .resizable()
                            .scaledToFill()
                            .frame(height: UIScreen.main.bounds.height * 0.5)
                            .clipped()
                            .overlay(
                                ZStack {
                                    overlayColor.opacity(0.55)
                                    LinearGradient(
                                        colors: [.clear, Color("black-500")],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                            )

                        VStack(alignment: .center, spacing: 8) {
                            Text(formattedDate)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.white.opacity(0.9))

                            Text(run.title)
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.white)

                            metricsRow
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 32)
                    }

                    // Body content
                    VStack(alignment: .leading, spacing: 16) {
                        Text(descriptionText)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: 370, alignment: .leading)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    Spacer(minLength: 40)
                }
            }

            // Back button (top-left)
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.55))
                        .frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 14)
            .padding(.leading, 16)
        }
        .ignoresSafeArea(edges: .top)
    }

    // Metrics row under title
    private var metricsRow: some View {
        HStack(spacing: 16) {
            if let dur = run.template.targetDurationSec {
                Label {
                    Text(Self.mmText(dur))
                        .font(.system(size: 15, weight: .regular))
                } icon: {
                    Image(systemName: "clock")
                }
            }
            Text("|")
            if let z = run.template.targetHRZone {
                Label {
                    Text("HR Zone \(z.rawValue)")
                        .font(.system(size: 15, weight: .regular))
                } icon: {
                    Image(systemName: "heart.fill")
                }
            }

//            Label {
//                Text(run.template.focus.rawValue.capitalized)
//            } icon: {
//                Image(systemName: "bolt.fill")
//            }
        }
        .font(.system(size: 13, weight: .medium))
        .foregroundColor(.white.opacity(0.95))
        .labelStyle(.titleAndIcon)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: run.date)
    }

    private var descriptionText: String {
        if let notes = run.template.notes, !notes.isEmpty {
            return notes
        } else {
            return "This session is designed to support your endurance with controlled effort and clear structure. Run at a comfortable pace, stay relaxed, and focus on finishing strong."
        }
    }

    // Color tint for header image based on run kind
    private var overlayColor: Color {
        switch run.template.kind {
        case .easy:
            return Color("easy")
        case .long:
            return Color("long")
        case .maf:
            return Color("maf")
        case .tempo:
            return Color("maf")
        case .intervals:
            return Color("maf")
        case .recovery:
            return Color("easy")
        }
    }

    private static func mmText(_ seconds: Int) -> String {
        let m = seconds / 60
        return "\(m) min"
    }
}


#Preview("Plan Detail") {
    let sampleTemplate = RunTemplate(
        name: "Easy Run",
        kind: .easy,
        focus: .base,
        targetDurationSec: 1800,
        targetDistanceKm: 3.0,
        targetHRZone: .z2,
        notes: "This is a very long description that repeats. This is a very long description that repeats.This is a very long description that repeats. This is a very long description that repeats.This is a very long description that repeats. This is a very long description that repeats.This is a very long description that repeats. This is a very long description that repeats.This is a very long description that repeats. This is a very long description that repeats."
    )
    
    let sampleRun = ScheduledRun(
        date: Date(),
        template: sampleTemplate,
        status: .planned
    )
    
    return NavigationStack {
        PlanDetailView(run: sampleRun)
            .preferredColorScheme(.dark)
    }
}
