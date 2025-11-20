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
        guard let d = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(OnboardingData.self, from: d)
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func mock() -> OnboardingData {
        OnboardingData(
            goal: .improveEndurance,
            personalInfo: PersonalInfo(
                age: 25,
                gender: "Male",
                weightKg: 70.0,
                heightCm: 175.0
            ),
            trainingPrefs: TrainingPrefs(
                daysPerWeek: 3,
                selectedDays: [6, 7, 1] // Jumat, sabtu, minggu
            ),
            personalBest: PersonalBest(
                distanceKm: 5.0,
                durationSeconds: 30 * 60 // 30 minutes
            ),
            recommendedPlan: .endurance,
            selectedPlan: .endurance,
            startDate: Date()
        )
    }

}
