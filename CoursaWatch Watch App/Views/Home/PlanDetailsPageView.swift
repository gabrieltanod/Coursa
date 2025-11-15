//
//  HomePageView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 26/10/25.
//

import SwiftUI

struct PlanDetailsPageView: View {

    let recPace: String = "7.30"
    
    let run: ScheduledRun
    
    var runTemplate: RunTemplate {
        run.template
    }
    
    var runningType: RunningType {
        RunningType(from: run.template.kind)
    }
    
    // Check if the run date is today
    var isToday: Bool {
        Calendar.current.isDate(run.date, inSameDayAs: Date())
    }
    
    
    @State private var navPath = NavigationPath()
    @Binding var appState: AppState
    
    @State private var isCountingDown = false
    
    enum CountdownStep: Hashable {
        case idle
        case paceRec
        case number(Int)
        case start
        
        var stateType: String {
            switch self {
            case .idle: return "idle"
            case .paceRec: return "pace"
            case .number: return "number"
            case .start: return "start"
            }
        }
    }
    
    @State private var countdownStep: CountdownStep = .idle
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var syncService: SyncService
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(alignment: .leading, spacing: 2) {
                        Text(runTemplate.name)
                            .font(.helveticaNeue(size: 20))
                        if let distance = runTemplate.targetDistanceKm {
                            Text("Distance: \(distance, specifier: "%.1f") km")
                                .font(.helveticaNeue(size: 16))
                        }
                        if let hrZone = runTemplate.targetHRZone {
                            Text("HR Zone: \(hrZone.rawValue)")
                                .font(.helveticaNeue(size: 16))
                        }
                        if let duration = runTemplate.targetDurationSec {
                            let minutes = duration / 60
                            let seconds = duration % 60
                            Text("Duration: \(minutes):\(String(format: "%02d", seconds))")
                                .font(.helveticaNeue(size: 16))
                        }
                        Text("Rec Pace: \(recPace)")
                            .font(.helveticaNeue(size: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.white)
                    
                    // Start Button
                    Button(action: {
                        if isToday {
                            startCountdownSequence()
                            workoutManager.startWorkout()
                        }
                    }) {
                        Text(isToday ? "Start" : "Not Available")
                            .font(.helveticaNeue(size: 20))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isToday ? Color("secondary") : Color.gray)
                            .foregroundColor(.black)
                            .cornerRadius(28)
                    }
                    .buttonStyle(.plain)
                    .disabled(!isToday)
                    
                }
                .padding(.horizontal, 15)
                .padding(.top, 10)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .disabled(isCountingDown)
            
            
            // Countdown Overlay
            if isCountingDown {
                Color.black
                    .ignoresSafeArea()
                
                Group {
                    switch countdownStep {
                        
                    case .idle:
                        EmptyView()
                        
                    case .paceRec:
                        VStack {
                            VStack(spacing: 8) {
                                Text("RECOMMENDED PACE")
                                    .font(.helveticaNeue(size: 16, weight: .bold))
                                    .foregroundColor(Color("secondary"))
                                
                                Text("7:30/KM")
                                    .font(.helveticaNeue(size: 38, weight: .bold))
                                    .foregroundColor(Color("secondary"))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .transition(.opacity.combined(with: .scale))
                        
                    case .number(let num):
                        VStack (spacing: 32){
                            Text("\(num)")
                                .font(.helveticaNeue(size: 96, weight: .bold))
                                .foregroundColor(Color("accentSecondary"))
                                .transition(.opacity.combined(with: .scale))
                                .id(num)
                            
                            Text("Be Ready!")
                                .font(.helveticaNeue(size: 15, weight: .bold))
                                .foregroundColor(Color("accentSecondary"))
                        }
                        
                    case .start:
                        Text("START!")
                            .font(.helveticaNeue(size: 40, weight: .bold))
                            .foregroundColor(Color("secondary"))
                            .transition(.opacity.combined(with: .scale))
                    }
                }
                .ignoresSafeArea()
                .id(countdownStep.stateType)
            }
            
        }
        .navigationBarBackButtonHidden(isCountingDown)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM yy"
        return formatter.string(from: date)
    }
    
    func startCountdownSequence() {
        Task {
            isCountingDown = true
            
            withAnimation { countdownStep = .paceRec }
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            withAnimation { countdownStep = .number(3) }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            withAnimation { countdownStep = .number(2) }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            withAnimation { countdownStep = .number(1) }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            withAnimation { countdownStep = .start }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // Store the current run in workoutManager so we can update it later
            workoutManager.currentRun = run
            
            appState = .running
        }
    }
}

