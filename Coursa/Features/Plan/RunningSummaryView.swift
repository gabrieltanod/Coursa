//
//  RunningSummaryView.swift
//  Coursa
//
//  Created by Zikar Nurizky on 10/11/25.
//

import SwiftUI

struct RunningSummaryView: View {
    let run: ScheduledRun

    var body: some View {
        ScrollView {
            VStack {
                // Masukin value ke RS card yes
                RunningSummaryCard(run: run)
                // Masukin value ke HR card yers
                HeartRateCard(run: run)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color("black-450"))
                    )

                // Masukin value ke sini jg uers
                PaceResultCard()
                Spacer()
            }
            .padding(24)
        }
        .background(Color("black-500"))
    }
}

#Preview("RunningSummaryView – Sample") {
    let sampleRun = ScheduledRun(
        date: Date(),
        template: RunTemplate(
            name: "Easy Run",
            kind: .easy,
            focus: .base,
            targetDurationSec: 30 * 60,
            targetDistanceKm: 5.0,
            targetHRZone: .z2,
            notes: "Easy aerobic run"
        )
    )

    return RunningSummaryView(run: sampleRun)
        .background(Color("black-500"))
}
