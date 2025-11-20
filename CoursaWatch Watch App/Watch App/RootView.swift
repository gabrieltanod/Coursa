//
//  RootView.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 19/11/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var appState: AppState = .planning
    @State private var finalSummaryData: RunningSummary?

    var body: some View {
        ZStack {
            if workoutManager.isCountingDown {
                CountdownView(count: workoutManager.countdownValue)
                
            } else if workoutManager.isRunning {
                RunningSessionView(
                        appState: $appState,
                        finalSummaryData: $finalSummaryData
                    )
            } else if workoutManager.showingSummary {
                if let summary = workoutManager.finalSummary {
                    SummaryPageView(
                        appState: Binding(
                            get: { .summary },
                            set: { newValue in
                                if newValue == .planning {
                                    workoutManager.showingSummary = false
                                }
                            }
                        ),
                        viewModel: SummaryPageViewModel(summary: summary),
                        workoutManager: workoutManager
                    )
                } else {
                    Text("Processing Summary...")
                }
                
            } else {
                HomePageView()
            }
        }
    }
}


struct CountdownView: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            Text("\(count)")
                .font(.system(size: 70, weight: .bold, design: .rounded))
                .foregroundColor(Color.orange)
                .transition(.scale)
                .id(count)
        }
        .animation(.easeInOut(duration: 0.2), value: count)
    }
}
