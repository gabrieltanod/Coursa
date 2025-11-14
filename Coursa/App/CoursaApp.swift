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
    
    
    // Watch Connectivity
    @StateObject private var syncService = SyncService()
    @StateObject private var planManager = PlanManager()

    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(router)
                .environmentObject(syncService)
                .environmentObject(planManager)
                .environment(\.colorScheme, .dark)
                .onAppear {
                    // Ensure a single SyncService instance is used app-wide
                    if planManager.syncService == nil {
                        planManager.syncService = syncService
                    }
                }
            
            
            // Watch Connectivity
//            WatchConnectivityDebugView()
//                .environmentObject(syncService)
//                .environmentObject(planManager)

        }
    }
}
