//
//  PlanStore.swift
//  Coursa
//
//  Created by Gabriel Tanod on 11/11/25.
//
//  Summary
//  -------
//  A simple adapter that lets `ManagePlanViewModel` read/write the
//  user's `GeneratedPlan` through the existing `OnboardingStore`.
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
