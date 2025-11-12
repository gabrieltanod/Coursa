//
//  HomePageView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 26/10/25.
//

import SwiftUI

enum NavigationRoute: Hashable {
    case workoutDetail(RunningPlan)
}

enum AppState {
    case planning
    case running
    case summary
}

struct HomePageView: View {
    @State private var navPath = NavigationPath()
    @State private var appState: AppState = .planning
    @StateObject private var workoutManager = WorkoutManager()
    @State private var finalRunningSummary: RunningSummary?
    @EnvironmentObject var syncService: SyncService
    
    // Dummy Data
    let myPlan = RunningPlan(
        date: Date(), title: "Easy Run", targetDistance: "3km", intensity: "HR Zone 2", recPace: "7:30/KM"
    )
    
    var body: some View {
        Group{
            switch appState {
                
            case .planning:
                NavigationStack(path: $navPath) {
                    ScrollView {
                        VStack(alignment: .leading){
                            
                            // ini buat ngetest session di watch jalan apa engga, bisa diganti kalo udah gadibutuhin
                            if syncService.isSessionActivated {
                                Text("Coursa")
                                    .foregroundColor(.green)
                                    .font(.system(size: 17, weight: .semibold))
                                    .padding(.bottom, 8)
                            } else {
                                Text("Coursa")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 17, weight: .semibold))
                                    .padding(.bottom, 8)
                            }
                            
                            Text("TODAY PLAN")
                                .font(.helveticaNeue(size: 13, weight: .regular))
                                .padding(.bottom, 4)
                            
                            NavigationLink(value: NavigationRoute.workoutDetail(myPlan)) {
                                PlanCardView(
                                    date: myPlan.date,
                                    targetDistance: myPlan.targetDistance,
                                    intensity: myPlan.intensity,
                                    runningType: .easyRun
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 4){
                            Text("UPCOMING PLAN")
                                .font(.helveticaNeue(size: 13, weight: .regular))
                                .padding(.bottom, 4)
                            
                            PlanCardView(
                                date: myPlan.date,
                                targetDistance: myPlan.targetDistance,
                                intensity: myPlan.intensity,
                                runningType: .mafTraining
                            )
                            PlanCardView(
                                date: myPlan.date,
                                targetDistance: myPlan.targetDistance,
                                intensity: myPlan.intensity,
                                runningType: .longRun
                            )
                            
                        }
                        .padding(.bottom, 40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    .padding(.horizontal, 15)
                    .ignoresSafeArea(edges: .bottom)
                    .navigationDestination(for: NavigationRoute.self) { route in
                        switch route {
                        case .workoutDetail(let plan):
                            PlanDetailsPageView(
                                title: plan.title,
                                targetDistance: plan.targetDistance,
                                intensity: plan.intensity,
                                recPace: plan.recPace,
                                plan: plan,
                                appState: $appState,
                            )
                        }
                    }
                }
                .background(Color("app"))
                .ignoresSafeArea()
                
            case .running:
                RunningSessionView(
                    appState: $appState,
                    finalSummaryData: $finalRunningSummary
                )
                .transition(.opacity)
                
            case .summary:
                if let summaryData = finalRunningSummary {
                    SummaryPageView(
                        appState: $appState, viewModel: SummaryPageViewModel(summary: summaryData)
                    )
                } else {
                    Text("Error: No Summary Data")
                }
                
            }
        }
        .environmentObject(workoutManager)
        .onAppear {
            workoutManager.requestAuthorization()
            workoutManager.syncService = syncService
        }
    }
}

