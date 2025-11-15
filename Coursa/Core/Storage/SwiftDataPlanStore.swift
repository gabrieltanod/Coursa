//
//  SwiftDataPlanStore.swift
//  Coursa
//
//  Created by Auto on 11/11/25.
//
//  SwiftData implementation of PlanStore

import Foundation
import SwiftData

final class SwiftDataPlanStore: PlanStore {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func load() -> GeneratedPlan? {
        let descriptor = FetchDescriptor<StoredGeneratedPlan>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        guard let stored = try? modelContext.fetch(descriptor).first else {
            return nil
        }
        
        return stored.toGeneratedPlan()
    }
    
    func save(_ plan: GeneratedPlan) {
        // Delete existing plan
        let descriptor = FetchDescriptor<StoredGeneratedPlan>()
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
        }
        
        // Create and save new plan
        let stored = StoredGeneratedPlan.from(plan)
        modelContext.insert(stored)
        
        do {
            try modelContext.save()
        } catch {
            print("⚠️ Failed to save plan to SwiftData: \(error)")
        }
    }
}

// MARK: - RunningSummary Store

final class SwiftDataSummaryStore {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func save(_ summary: RunningSummary, runId: String?) {
        let stored = StoredRunningSummary.from(summary, runId: runId)
        modelContext.insert(stored)
        
        do {
            try modelContext.save()
        } catch {
            print("⚠️ Failed to save summary to SwiftData: \(error)")
        }
    }
    
    func load(for runId: String) -> RunningSummary? {
        let descriptor = FetchDescriptor<StoredRunningSummary>(
            predicate: #Predicate<StoredRunningSummary> { $0.runId == runId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        guard let stored = try? modelContext.fetch(descriptor).first else {
            return nil
        }
        
        return stored.toRunningSummary()
    }
    
    func loadAll() -> [RunningSummary] {
        let descriptor = FetchDescriptor<StoredRunningSummary>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        guard let stored = try? modelContext.fetch(descriptor) else {
            return []
        }
        
        return stored.map { $0.toRunningSummary() }
    }
}

