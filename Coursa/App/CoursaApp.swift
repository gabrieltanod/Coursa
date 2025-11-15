//
//  CoursaApp.swift
//  Coursa
//
//  Created by Gabriel Tanod on 13/10/25.
//

import SwiftUI
import SwiftData

@main
struct CoursaApp: App {
    
    @StateObject private var router = AppRouter()
    @StateObject private var planSession = PlanSessionStore()
    
    
    // Watch Connectivity
    @StateObject private var syncService = SyncService()
    @StateObject private var planManager = PlanManager()
    
    // SwiftData ModelContainer
    let container: ModelContainer
    
    init() {
        let schema = Schema([
            StoredGeneratedPlan.self,
            StoredScheduledRun.self,
            StoredRunTemplate.self,
            StoredRunMetrics.self,
            StoredRunningSummary.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    
    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(router)
                .environmentObject(syncService)
                .environmentObject(planManager)
                .environmentObject(planSession)
                .environment(\.colorScheme, .dark)

                .modelContainer(container)
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
