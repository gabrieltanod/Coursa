//
//  WeeklyPlanOverViewCard.swift
//  Coursa
//
//  Created by Gabriel Tanod on 18/11/25.
//

import SwiftUI

struct WeeklyPlanOverviewCard: View {
    let weekIndex: Int
    let runs: [ScheduledRun]
    var onSeeOverview: (() -> Void)?
    var showsButton: Bool = false

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Week title
            Text("Week \(weekIndex)")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("white-500"))

            // Runs list
            VStack(alignment: .leading, spacing: 8) {
                ForEach(runs) { run in
                    HStack(spacing: 12) {
                        Text(weekday(for: run.date))
                            .font(.system(size: 15, weight: .regular))
                            .frame(width: 32, alignment: .leading)

                        Text(run.title)
                            .font(.system(size: 16, weight: .regular))

                        Text("•")
                            .font(.system(size: 16, weight: .semibold))

                        Text(spec(for: run))
                            .font(.system(size: 15, weight: .regular))
                    }
                    .foregroundColor(Color("white-500"))

                }
            }

            // Button (placeholder action)
            if showsButton, let onSeeOverview {
                Button(action: onSeeOverview) {
                    Text("See Plan Overview")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 8)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("black-475"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .inset(by: 0.5)
                .stroke(Color(red: 0.25, green: 0.25, blue: 0.25), lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func weekday(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateFormat = "EEE"  // Tue, Fri, Sun
        return f.string(from: date)
    }

    private func spec(for run: ScheduledRun) -> String {
        if let distance = run.template.targetDistanceKm {
            // 5 km, 10 km
            return "\(Int(distance)) km"
        }
        if let duration = run.template.targetDurationSec {
            let minutes = duration / 60
            return "\(minutes) min"
        }
        return ""  // fallback
    }
}

#Preview {
    // Dummy preview data
    let sampleRuns: [ScheduledRun] = [
        ScheduledRun(
            date: Date(),
            template: RunTemplate(
                name: "MAF Training",
                kind: .easy,
                focus: .endurance,
                targetDurationSec: 30 * 60,
                targetDistanceKm: nil,
                targetHRZone: .z2,
                notes: ""
            )
        ),
        ScheduledRun(
            date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            template: RunTemplate(
                name: "Easy Run",
                kind: .easy,
                focus: .endurance,
                targetDurationSec: nil,
                targetDistanceKm: 5,
                targetHRZone: .z2,
                notes: ""
            )
        ),
        ScheduledRun(
            date: Calendar.current.date(byAdding: .day, value: 4, to: Date())!,
            template: RunTemplate(
                name: "Long Run",
                kind: .long,
                focus: .endurance,
                targetDurationSec: nil,
                targetDistanceKm: 10,
                targetHRZone: .z2,
                notes: ""
            )
        ),
    ]

    ZStack {
        Color("black-500").ignoresSafeArea()
        WeeklyPlanOverviewCard(weekIndex: 1, runs: sampleRuns)
            .padding()
    }
}
