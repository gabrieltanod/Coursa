//
//  StoreManager.swift
//  Coursa
//
//  Created by Auto on 11/11/25.
//
//  Shared store manager for SwiftData

import Foundation
import SwiftData

@MainActor
final class StoreManager {
    static let shared = StoreManager()
    
    private var modelContext: ModelContext?
    private var planStore: PlanStore?
    private var summaryStore: SwiftDataSummaryStore?
    
    private init() {}
    
    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.planStore = SwiftDataPlanStore(modelContext: modelContext)
        self.summaryStore = SwiftDataSummaryStore(modelContext: modelContext)
    }
    
    var currentPlanStore: PlanStore {
        if let planStore = planStore {
            return planStore
        }
        // Fallback to UserDefaults if SwiftData not configured
        return UserDefaultsPlanStore.shared
    }
    
    var currentSummaryStore: SwiftDataSummaryStore? {
        return summaryStore
    }
}

