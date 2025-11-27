//
//  PaceRecommender.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 24/11/25.
//

import Foundation
import SwiftUI

struct WeeklyPaceTargets: Codable, Hashable {
    var easyPaceSeconds: Double
    var longPaceSeconds: Double
    var mafPaceSeconds: Double
    
    /// Helper to retrieve the correct pace for a specific RunKind
    func pace(for kind: RunKind) -> Double {
        switch kind {
        case .easy: return easyPaceSeconds
        case .long: return longPaceSeconds
        case .maf: return mafPaceSeconds
        default: return easyPaceSeconds
        }
    }
}

class PaceRecommender {

    
    static func calculateTargets(currentWeek: Int) -> WeeklyPaceTargets {
        let onboardingData = OnboardingStore.load()
        
        var basePaceSeconds: Double = 450.0 // Default 7:30/km
        
        // Helper to calculate BMI-based pace
        func getBMIPace() -> Double {
            guard let heightCm = onboardingData?.personalInfo.heightCm,
                  let weightKg = onboardingData?.personalInfo.weightKg,
                  heightCm > 0 // Prevent crash from dividing by zero
            else {
                // Fallback: If we don't have data, assume standard pace
                return 450.0
            }
            
            let heightM = heightCm / 100
            let bmi = weightKg / (heightM * heightM)
            
            var pace = 450.0
            if bmi > 30 { pace += 45 }
            else if bmi > 25 { pace += 20 }
            return pace
        }
        
        if let pb = onboardingData?.personalBest, pb.distanceKm > 0, pb.durationSeconds > 0 {
            let racePace = Double(pb.durationSeconds) / pb.distanceKm
            
            if racePace > 150 && racePace < 720{
                basePaceSeconds = racePace + 100
            } else {
                print("⚠️ Abnormal Race Pace Detected: \(racePace) s/km. Falling back to BMI.")
                basePaceSeconds = getBMIPace()
            }
        } else {
            basePaceSeconds = getBMIPace()
        }
        
        // 3. Progression Logic
        var speedMultiplier = 1.0
        var efficiencyMultiplier = 1.0
        
        switch currentWeek {
        case 1...3:
            speedMultiplier = 1.0
            efficiencyMultiplier = 1.0
        case 4...6:
            speedMultiplier = 0.96
            efficiencyMultiplier = 0.98
        case 7...9:
            speedMultiplier = 0.92
            efficiencyMultiplier = 0.96
        default:
            speedMultiplier = 1.0
            efficiencyMultiplier = 1.0
        }
        
        return WeeklyPaceTargets(
            easyPaceSeconds: basePaceSeconds * efficiencyMultiplier,
            longPaceSeconds: (basePaceSeconds + 15.0) * efficiencyMultiplier,
            mafPaceSeconds: basePaceSeconds * speedMultiplier
        )
    }
    
    
}
