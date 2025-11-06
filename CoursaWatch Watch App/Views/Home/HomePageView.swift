//
//  HomePageView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 26/10/25.
//

import SwiftUI

enum NavigationRoute: Hashable {
    case workoutDetail(Plan)
}

enum AppState {
    case planning
    case running
    case summary
}

struct HomePageView: View {
    @State private var navPath = NavigationPath()
    @State private var isSessionActive = false
    @State private var appState: AppState = .planning
    @StateObject private var workoutManager = WorkoutManager()
    @State private var finalWorkoutSummary: WorkoutSummary?
    
    // Dummy Data
    let myPlan = Plan(
        date: Date(), title: "Easy Run", targetDistance: "3km", intensity: "HR Zone 2", description: "Keep conversational pace for 3km. Your recommended pace is 7:30/km."
    )
    
    var body: some View {
        Group{
            switch appState {
                
            case .planning:
                NavigationStack(path: $navPath) {
                    ScrollView {
                        VStack(alignment: .leading){
                            Text("TODAY'S PLAN")
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.bottom, 4)
                            
                            NavigationLink(value: NavigationRoute.workoutDetail(myPlan)) {
                                PlanCardView(
                                    date: myPlan.date,
                                    title: myPlan.title,
                                    targetDistance: myPlan.targetDistance,
                                    intensity: myPlan.intensity
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 8){
                            Text("UPCOMING PLAN")
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.bottom, 4)
                            
                            PlanCardView(date: Date(), title: "MAF Training", targetDistance: "3km", intensity: "HR Zone 2")
                            PlanCardView(date: Date(), title: "Long Run", targetDistance: "3km", intensity: "HR Zone 2")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    .padding(.horizontal, 9)
                    .ignoresSafeArea(edges: .bottom)
                    .navigationDestination(for: NavigationRoute.self) { route in
                        switch route {
                        case .workoutDetail(let plan):
                            PlanDetailsPageView(
                                title: plan.title,
                                targetDistance: plan.targetDistance,
                                intensity: plan.intensity,
                                description: plan.description,
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
                    finalSummaryData: $finalWorkoutSummary
                )
                .transition(.opacity)
                
            case .summary:
                if let summaryData = finalWorkoutSummary {
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
        }
    }
}
