//
//  HomePageView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 26/10/25.
//

import SwiftUI

struct PlanDetailsPageView: View {
    
    let plan: RunningPlan
    @State private var navPath = NavigationPath()
    @Binding var appState: AppState
    
    @State private var isCountingDown = false
    
    enum CountdownStep: Hashable {
        case idle
        case number(Int)
        case start
        
        var stateType: String {
            switch self {
            case .idle: return "idle"
            case .number: return "number"
            case .start: return "start"
            }
        }
    }
    
    @State private var countdownStep: CountdownStep = .idle
    @EnvironmentObject var workoutManager: WorkoutManager
    @ObservedObject var syncService = SyncService.shared
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                
                Spacer()
                
                // Header
                VStack(spacing: 2) {
                    Text("Recommended Pace:")
                        .font(.helveticaNeue(size: 17))
                        .foregroundColor(Color("secondary"))
                    
                    Text(plan.recPace ?? "7:30/KM")
                        .font(.helveticaNeue(size: 30))
                        .foregroundColor(Color("secondary"))
                }
                .frame(maxWidth: .infinity)
                
                // Start Button
                VStack{
                    Button(action: {
                        workoutManager.currentRunId = plan.id
                        workoutManager.startCountdown()
                    }) {
                        Text("Start")
                            .font(.helveticaNeue(size: 20))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color("secondary"))
                            .foregroundColor(.black)
                            .cornerRadius(28)
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .disabled(isCountingDown)
            
            
            // Countdown Overlay
            if isCountingDown {
                Color.black
                    .ignoresSafeArea()
                
                Group {
                    switch countdownStep {
                        
                    case .idle:
                        EmptyView()
                        
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
        .onAppear {
            syncService.connect()}
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
            
            withAnimation { countdownStep = .number(3) }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            withAnimation { countdownStep = .number(2) }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            withAnimation { countdownStep = .number(1) }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            withAnimation { countdownStep = .start }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            appState = .running
        }
    }
}
