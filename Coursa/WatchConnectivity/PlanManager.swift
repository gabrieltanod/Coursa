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
    
    
    @Published var name: String = ""
    @Published var kind: RunKind?
    @Published var targetDistance: Double = 0.0
    @Published var targetHRZone: HRZone?
    @Published var recPace: String = ""
    
    @Published var finalPlan: RunningPlan?
    
    var syncService: SyncService?
    
    private func getSyncService() -> SyncService {
        if let service = syncService {
            return service
        }
        let service = SyncService()
        syncService = service
        return service
    }
    
    func buttonSendPlanTapped() -> RunningPlan? {
        
        let plan = RunningPlan(
            date: Date(),
            name: self.name,
            kind: self.kind,
            targetDistance: self.targetDistance,
            targetHRZone: self.targetHRZone,
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
