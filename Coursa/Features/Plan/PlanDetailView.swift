//
//  PlanDetailView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 28/10/25.
//

import SwiftUI

struct PlanDetailView: View {
    let run: ScheduledRun
    @State private var isRunning = false
    @State private var didComplete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Hero / banner placeholder
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 160)
                    .overlay(Image(systemName: "triangle").font(.system(size: 40)).foregroundStyle(.gray))

                Text(run.title)
                    .font(.largeTitle.bold())
                    .padding(.top, 4)

                // Specs row
                HStack(spacing: 12) {
                    if let dur = run.template.targetDurationSec {
                        Label(Self.mmText(dur), systemImage: "clock")
                    }
                    if let z = run.template.targetHRZone {
                        Label("HR Zone \(z.rawValue)", systemImage: "heart")
                    }
                    Label(run.template.focus.rawValue.capitalized, systemImage: "bolt")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                // Notes / description
                Text(run.template.notes ?? "This session targets \(run.template.focus.rawValue) using \(run.template.kind.rawValue) training. Keep it controlled and consistent.")
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.top, 4)

                Spacer(minLength: 24)

                // CTA
                Button {
                    isRunning.toggle()
                    // later: navigate to live workout / HealthKit
                } label: {
                    Text(didComplete ? "VIEW SUMMARY" : (isRunning ? "STOP" : "START RUNNING"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(.black)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .navigationTitle(run.date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
    }

    private static func mmText(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%d min", m + (s > 0 ? 1 : 0))
    }
}
