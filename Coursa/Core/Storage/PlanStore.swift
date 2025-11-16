//
//  PlanStore.swift
//  Coursa
//
//  Created by Gabriel Tanod on 11/11/25.
//
//  Summary
//  -------
//  Minimal persistence for GeneratedPlan using UserDefaults.
//  Keeps v1 lightweight and easy to migrate later.
//
//  Responsibilities
//  ----------------
//  - load()/save() of GeneratedPlan as JSON.
//  - No migration logic yet (v1 lightweight).
//  - Isolated behind PlanStore protocol for future SwiftData.
//

import Foundation

protocol PlanStore {
    func load() -> GeneratedPlan?
    func save(_ plan: GeneratedPlan)
}

/// Simple persistence using UserDefaults for now.
/// Replace with file-based / CloudKit / whatever later.
final class UserDefaultsPlanStore: PlanStore {
    static let shared = UserDefaultsPlanStore()
    private let key = "coursa.generatedPlan"

    func load() -> GeneratedPlan? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(GeneratedPlan.self, from: data)
    }

    func save(_ plan: GeneratedPlan) {
        guard let data = try? JSONEncoder().encode(plan) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
