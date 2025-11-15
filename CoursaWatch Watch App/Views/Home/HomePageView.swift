//
//  HomePageView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 26/10/25.
//

import SwiftUI

enum NavigationRoute: Hashable {
    case workoutDetail(ScheduledRun)
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

    var body: some View {
        Group {
            switch appState {
                
            case .planning:
                NavigationStack(path: $navPath) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            
                            // Debug indicator for session state
                            Text("Coursa")
                                .foregroundColor(syncService.isSessionActivated ? .green : .orange)
                                .font(.system(size: 17, weight: .semibold))
                                .padding(.bottom, 8)
                            
                            if let plan = syncService.plan {
                                // Separate runs by today vs upcoming
                                let calendar = Calendar.current
                                
                                let todayRuns = plan.runs.filter { run in
                                    calendar.isDate(run.date, inSameDayAs: Date()) && run.status != .completed
                                }.sorted { $0.date < $1.date }
                                
                                let upcomingRuns = plan.runs.filter { run in
                                    run.date > Date() && !calendar.isDate(run.date, inSameDayAs: Date())
                                }.sorted { $0.date < $1.date }
                                
                                // TODAY PLAN section - always show
                                Text("TODAY PLAN")
                                    .font(.helveticaNeue(size: 13, weight: .regular))
                                    .padding(.bottom, 4)
                                
                                if !todayRuns.isEmpty {
                                    ForEach(todayRuns) { run in
                                        NavigationLink(value: NavigationRoute.workoutDetail(run)) {
                                            PlanCardView(run: run)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                } else {
                                    Text("There is no running session today")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .padding(.bottom, 8)
                                }
                                
                                // UPCOMING PLAN section - grouped by week
                                if !upcomingRuns.isEmpty {
                                    Text("UPCOMING PLAN")
                                        .font(.helveticaNeue(size: 13, weight: .regular))
                                        .padding(.top, 16)
                                        .padding(.bottom, 4)
                                    
                                    // Group runs by week
                                    let groupedByWeek = Dictionary(grouping: upcomingRuns) { run in
                                        calendar.dateInterval(of: .weekOfYear, for: run.date)?.start ?? run.date
                                    }
                                    
                                    let sortedWeeks = groupedByWeek.keys.sorted()
                                    
                                    ForEach(sortedWeeks, id: \.self) { weekStart in
                                        if let weekRuns = groupedByWeek[weekStart] {
                                            VStack(alignment: .leading, spacing: 8) {
                                                Text(formatWeekRange(weekStart: weekStart))
                                                    .font(.helveticaNeue(size: 11, weight: .regular))
                                                    .foregroundColor(.gray)
                                                    .padding(.top, 8)
                                                
                                                ForEach(weekRuns.sorted { $0.date < $1.date }) { run in
                                                    NavigationLink(value: NavigationRoute.workoutDetail(run)) {
                                                        PlanCardView(run: run)
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                Text("TODAY PLAN")
                                    .font(.helveticaNeue(size: 13, weight: .regular))
                                    .padding(.bottom, 4)
                                
                                Text("There is no running session today")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.bottom, 40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 15)
                    .ignoresSafeArea(edges: .bottom)
                    .navigationDestination(for: NavigationRoute.self) { route in
                        switch route {
                        case .workoutDetail(let run):
                            PlanDetailsPageView(
                                run: run,
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
                        viewModel: SummaryPageViewModel(summary: summaryData)
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
    
    private func formatWeekRange(weekStart: Date) -> String {
        let calendar = Calendar.current
        guard let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let startStr = formatter.string(from: weekStart)
        let endStr = formatter.string(from: weekEnd)
        
        return "Week of \(startStr) - \(endStr)"
    }
}
