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
//                GoalCard(type: type)
                
                RunningSummaryCard(run: run)
                
                HeartRateCard(run: run)
            }
            .padding(24)
        }
        .background(Color("black-500"))
    }
}

//#Preview("RunningSummaryView – Sample") {
//    let sampleRun = ScheduledRun(
//        date: Date(),
//        template: RunTemplate(
//            name: "Easy Run",
//            kind: .easy,
//            focus: .base,
//            targetDurationSec: 30 * 60,
//            targetDistanceKm: 5.0,
//            targetHRZone: .z2,
//            notes: "Easy aerobic run"
//        )
//    )
//
//    return RunningSummaryView(run: sampleRun)
//        .background(Color("black-500"))
//}
