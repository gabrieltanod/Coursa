//
//  CoreTabView.swift
//  Coursa
//
//  Created by Gabriel Tanod on 03/11/25.
//

import SwiftUI

struct CoreTabView: View {
    let onboardingData: OnboardingData
    @StateObject private var planSession = PlanSessionStore()

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
                    .environmentObject(planSession)
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }

            NavigationStack {
                PlanView(vm: PlanViewModel(data: onboardingData))
                    .environmentObject(planSession)
            }
            .tabItem {
                Label("Plan", systemImage: "figure.run")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(Color("green-500"))
    }
}
