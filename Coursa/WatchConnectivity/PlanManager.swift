//
//  PlanManager.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 11/11/25.
//


import Foundation
import Combine
import SwiftUI

class PlanManager: NSObject, ObservableObject {
    
    
    @Published var title: String = ""
    @Published var distance: String = ""
    @Published var intensity: String = ""
    @Published var recPace: String = ""
    
    @Published var finalPlan: RunningPlan?
    // SyncService - can be injected from environment or will use own instance
    var syncService: SyncService?
    
    // Lazy initialization of syncService if not provided
    private func getSyncService() -> SyncService {
        if let service = syncService {
            return service
        }
        // Create a new instance if not provided (fallback)
        let service = SyncService()
        syncService = service
        return service
    }
    
    func buttonSendPlanTapped() -> RunningPlan? {
        
        let plan = RunningPlan(
            date: Date(),
            title: self.title,
            targetDistance: self.distance,
            intensity: self.intensity,
            recPace: self.recPace
        )
        
        sendPlanToWatchOS(plan)
        
        return plan
    }

    
    func sendPlanToWatchOS(_ plan: RunningPlan) {
        let service = getSyncService()
        DispatchQueue.main.async {
            service.sendPlanToWatchOS(plan: plan)
        }
    }
    
    
}
