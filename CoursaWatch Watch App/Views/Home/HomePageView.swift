//
//  HomePageView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 26/10/25.
//

import SwiftUI
import Combine

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
    @EnvironmentObject private var workoutManager: WorkoutManager
    @State private var finalRunningSummary: RunningSummary?
    
    @EnvironmentObject var syncService: SyncService

    var body: some View {
        Group {
            switch appState {
                
            case .planning:
                NavigationStack(path: $navPath) {
                    ScrollView {
                        VStack(alignment: .leading) {
                            
                            // Debug indicator for session state
                            Text("Coursa")
                                .foregroundColor(syncService.isSessionActivated ? .green : .orange)
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.bottom, 8)
                            
                            Text("TODAY PLAN")
                                .font(.helveticaNeue(size: 13, weight: .regular))
                                .padding(.bottom, 4)
                            
                            if let plan = syncService.plan {
                                NavigationLink(value: NavigationRoute.workoutDetail(plan)) {
                                    PlanCardView(plan: plan)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Text("No running plan available")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("UPCOMING PLAN")
                                    .font(.helveticaNeue(size: 13, weight: .regular))
                                    .padding(.bottom, 4)
                            }
                            .padding(.bottom, 40)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 15)
                    .ignoresSafeArea(edges: .bottom)
                    .navigationDestination(for: NavigationRoute.self) { route in
                        switch route {
                        case .workoutDetail(let plan):
                            PlanDetailsPageView(
                                plan: plan,
                                appState: $appState
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
                        appState: $appState,
                        viewModel: SummaryPageViewModel(summary: summaryData), workoutManager: workoutManager
                    )
                } else {
                    Text("Error: No Summary Data")
                        .foregroundColor(.red)
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
