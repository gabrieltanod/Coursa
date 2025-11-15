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
    
    @Published var finalPlan: GeneratedPlan?      // The real generated plan
    var syncService: SyncService?
    
    private func getSyncService() -> SyncService {
        if let service = syncService { return service }
        let service = SyncService()
        syncService = service
        return service
    }
    
    func sendPlanToWatchOS(_ plan: GeneratedPlan) {
        let service = getSyncService()
        DispatchQueue.main.async {
            service.sendPlanToWatchOS(plan: plan)
        }
    }
    
    func buttonSendPlanTapped() {
        guard let plan = finalPlan else {
            print("❌ PlanManager: No GeneratedPlan available to send")
            return
        }
        
        sendPlanToWatchOS(plan)
    }
    

}
