//
//  ControlPageView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct ControlPageView: View {
    @Binding var timeElapsed: Double
    @Binding var isRunning: Bool
    @Binding var timer: Timer?
    @Binding var appState: AppState
    @State private var showingConfirmation = false
    @Binding var finalSummaryData: RunningSummary?
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        HStack(spacing: 46) {
            ButtonControlView(
                isRunning: .constant(false),
                action: {
                    showingConfirmation = true
                },
                iconName: "icon-end",
                color: "destructive",
                status: "END"
            )
            .confirmationDialog(
                "Do you want to end?",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button("End Workout", role: .destructive) {
                    endSessionAndSaveData()
                    reset()
                }
                .foregroundColor(Color("Red"))
                .background(Color("destructive"))
            }
            
            ButtonControlView(
                isRunning: $isRunning,
                action: toggleStartPause,
                iconName: isRunning ? "icon-pause" : "icon-resume",
                color: isRunning ? "warning" : "success",
                status: isRunning ? "PAUSE" : "RESUME",
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("app"))
    }
    
    func toggleStartPause() {
        if isRunning { pause() } else { start() }
        isRunning.toggle()
    }
    
    func start() {
        timer?.invalidate()
        let newTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            timeElapsed += 0.01
        }
        RunLoop.main.add(newTimer, forMode: .common)
        timer = newTimer
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        timeElapsed = 0.0
        isRunning = false
    }
    
    func endSessionAndSaveData() {
        let summary = workoutManager.stopWorkoutAndReturnSummary()
        
        if let finalData = summary {
            // Send summary to iOS
            workoutManager.sendSummaryToiOS(finalData)
            
            if finalData.totalTime < 10 {
                appState = .planning
            } else {
                finalSummaryData = finalData
                appState = .summary
            }
        } else {
            appState = .planning
        }
    }
    
}
