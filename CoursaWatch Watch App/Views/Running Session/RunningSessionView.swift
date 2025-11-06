//
//  RunningSessionView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 24/10/25.
//

import SwiftUI

struct RunningSessionView: View {
    @State private var timeElapsed: Double = 0.0
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    @State private var selectedHorizontalTab = 1
    @State private var selectedVerticalTab = 0
    @State private var hasStarted: Bool = false
    
    @Binding var appState: AppState
    @Binding var finalSummaryData: WorkoutSummary?
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        TabView(selection: $selectedHorizontalTab) {
            ControlPageView(
                timeElapsed: $timeElapsed,
                isRunning: $isRunning,
                timer: $timer,
                appState: $appState,
                finalSummaryData: $finalSummaryData
            )
            .tag(0)
            
            ZStack(alignment: .top) {
                TabView(selection: $selectedVerticalTab) {
                    // Halaman 1: Overview
                    OverviewPageView()
                        .tag(0)
                    
                    // Halaman 2: Heart Rate
                    HeartRateView()
                        .tag(1)
                    
                    // Halaman 3: Pace
                    PaceView()
                        .tag(2)
                    
                    // Halaman 4: Elevation
                    ElevationView()
                        .tag(3)
                }
                .tabViewStyle(.verticalPage)
                .ignoresSafeArea()
                
                
                // Header
                HeaderTimerView(timeElapsed: $timeElapsed)
                
            }
            .tag(1)
            .ignoresSafeArea()
        }
        .onAppear {
            start()
        }
    }
    
    func start() {
        isRunning = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {_ in
            timeElapsed += 0.01
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        pause()
        timeElapsed = 0.0
    }

}
