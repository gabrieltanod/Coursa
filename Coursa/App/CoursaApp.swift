//
//  CoursaApp.swift
//  Coursa
//
//  Created by Gabriel Tanod on 13/10/25.
//

import SwiftUI

@main
struct CoursaApp: App {
    
    @StateObject private var router = AppRouter()
    @StateObject private var planSession = PlanSessionStore()
    
    
    // Watch Connectivity
    @StateObject private var syncService = SyncService()
    @StateObject private var planManager = PlanManager.shared

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(router)
                .environmentObject(planManager)
                .environmentObject(syncService)
                .environmentObject(planSession)
                .environment(\.colorScheme, .dark)
                .onAppear {
                    // Ensure a single SyncService instance is used app-wide
                    if planManager.syncService == nil {
                        planManager.syncService = syncService
                    }
                    planManager.planSession = planSession
                }
            
            
            
            // Watch Connectivity
//            WatchConnectivityDebugView()
//                .environmentObject(syncService)
//                .environmentObject(planManager)

        }
    }
}
