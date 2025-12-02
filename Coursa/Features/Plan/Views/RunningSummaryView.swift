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
            VStack (spacing: 20) {
                GoalCard(run: run)
                
                RunningSummaryCard(run: run)
                
                HeartRateCard(run: run)
            }
            .padding(24)
        }
        .background(Color("black-500"))
    }
}

#Preview {
    let mockTemplate = RunTemplate(
        name: "Easy Run",
        kind: .easy,
        focus: .base,
        targetDurationSec: 1800,
        targetDistanceKm: nil,
        targetHRZone: .z2,
        notes: "Keep your heart rate steady and enjoy the view."
    )

    let sampleRun = ScheduledRun(
        id: UUID().uuidString,
        date: Date(),
        template: mockTemplate
    )

    NavigationView {
        RunningSummaryView(run: sampleRun)
            .environment(\.dynamicTypeSize, .accessibility5)
    }
}
