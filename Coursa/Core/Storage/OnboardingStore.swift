//
//  OnboardingStore.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

// ABSTRACT: ini buat ngestore/skip the onboarding phase once the users done it

import Foundation

enum OnboardingStore {
    private static let key = "onboarding_data"

    static func save(_ data: OnboardingData) {
        let enc = JSONEncoder()
        if let d = try? enc.encode(data) {
            UserDefaults.standard.set(d, forKey: key)
        }
    }

    static func load() -> OnboardingData? {
        guard let d = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(OnboardingData.self, from: d)
    }
}
