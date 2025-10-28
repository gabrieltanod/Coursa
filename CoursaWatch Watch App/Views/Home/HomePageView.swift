//
//  HomePageView.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 26/10/25.
//

import SwiftUI

struct Plan: Hashable, Codable {
    var date: Date
    var title: String
    var targetDistance: String
    var intensity: String
    var description: String
}

enum NavigationRoute: Hashable {
    case workoutDetail(Plan) // Rute ke detail, membawa data 'Plan'
//    case runningSession(Bool) // Rute ke sesi lari, membawa flag 'auto-start'
}

enum AppState {
    case planning       // Menampilkan daftar rencana (NavStack)
    case running        // Menampilkan RunningSessionView
    case summary        // Menampilkan SummaryPageView
}

struct HomePageView: View {
    @State private var navPath = NavigationPath()
    @State private var isSessionActive = false
    @State private var appState: AppState = .planning
    
    // Data dummy untuk contoh
    let myPlan = Plan(
        date: Date(),
        title: "Easy Run",
        targetDistance: "3km",
        intensity: "HR Zone 2",
        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    )
    
    var body: some View {
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
                        
                        PlanCardView(date: Date(), title: "Easy Run", targetDistance: "3km", intensity: "HR Zone 2")
                        PlanCardView(date: Date(), title: "Easy Run", targetDistance: "3km", intensity: "HR Zone 2")
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
                appState: $appState
            )
            .transition(.opacity)
            
        case .summary:
            SummaryPageView(
                appState: $appState
            )
            .transition(.opacity)
        }
    }
}



#Preview {
    HomePageView()
}

