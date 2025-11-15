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
    @EnvironmentObject var syncService: SyncService
    
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
            // Check if workout duration is >= 60 seconds
            if finalData.totalTime >= 60 {
                // Workout is valid - send summary to iOS and mark as completed
                workoutManager.sendSummaryToiOS(finalData)
                
                // Update plan on watchOS to mark run as completed
                if let run = workoutManager.currentRun {
                    updatePlanOnWatchOS(run: run, summary: finalData)
                }
                
                finalSummaryData = finalData
                appState = .summary
            } else {
                // Workout is too short - don't send summary, don't mark as completed
                print("⚠️ Workout duration (\(finalData.totalTime)s) is less than 60 seconds. Not marking as completed.")
                appState = .planning
            }
        } else {
            appState = .planning
        }
    }
    
    private func updatePlanOnWatchOS(run: ScheduledRun, summary: RunningSummary) {
        guard var plan = syncService.plan else {
            print("⚠️ watchOS: No plan available to update")
            return
        }
        
        let calendar = Calendar.current
        let today = Date()
        
        // Find the run for today's date
        guard let runIndex = plan.runs.firstIndex(where: { r in
            calendar.isDate(r.date, inSameDayAs: today) && r.id == run.id
        }) else {
            print("⚠️ watchOS: No run found for today's date")
            return
        }
        
        // Update the run's actual metrics from summary
        plan.runs[runIndex].actual.elapsedSec = Int(summary.totalTime)
        plan.runs[runIndex].actual.distanceKm = summary.totalDistance
        plan.runs[runIndex].actual.avgHR = Int(summary.averageHeartRate)
        // Convert pace from minutes per km to seconds per km
        plan.runs[runIndex].actual.avgPaceSecPerKm = Int(summary.averagePace * 60)
        
        // Mark as completed
        plan.runs[runIndex].status = .completed
        
        // Update the plan in syncService
        syncService.plan = plan
        
        print("✅ watchOS: Updated run for \(today) with summary data and marked as completed")
    }
    
}
