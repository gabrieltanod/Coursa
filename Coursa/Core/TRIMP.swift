//
//  TRIMP.swift
//  Coursa
//
//  Created by Gabriel Tanod on 12/11/25.
//
//  Summary
//  -------
//  Implements the Emig & Peltonen (2020) TRIMP model as described in the PRD.
//  Converts session duration + relative intensity (avgHR / maxHR) into a
//  single training load value. TRIMP is summed across a week to produce
//  WeeklyTRIMP for the adaptation engine.
//
//  Responsibilities
//  ----------------
//  - Compute per-session TRIMP using gender-specific constants.
//  - Sum TRIMP over a list of runs (e.g. one training week).
//  - Provide v1-friendly overloads that work without a full UserProfile yet.
//
//  Notes
//  -----
//  - For now, maxHR is passed in or defaulted. Later, this should come from
//    a UserProfile (MHR = 220 - age, editable by the user).
//

import Foundation

/// Simple representation of sex used for TRIMP constants.
/// You can later replace this with whatever you use in UserProfile.
enum TRIMPGender {
    case male
    case female
}

enum TRIMP {

    // Gender-specific constants from Emig & Peltonen (2020)
    private static func constants(for gender: TRIMPGender) -> (k1: Double, k2: Double) {
        switch gender {
        case .male:
            return (k1: 0.64, k2: 1.92)
        case .female:
            return (k1: 0.86, k2: 1.67)
        }
    }

    /// Core TRIMP calculation for a single session.
    ///
    /// - Parameters:
    ///   - durationSec: Training time in seconds.
    ///   - avgHR: Average heart rate over the session (optional).
    ///   - maxHR: User's maximum heart rate (MHR).
    ///   - gender: TRIMPGender (male/female) to pick the right constants.
    ///
    /// - Returns: TRIMP value for this session (Double).
    static func sessionTRIMP(
        durationSec: Int,
        avgHR: Int?,
        maxHR: Double,
        gender: TRIMPGender
    ) -> Double {
        guard durationSec > 0, maxHR > 0 else { return 0 }

        let (k1, k2) = constants(for: gender)

        // Ttrain in minutes
        let Ttrain = Double(durationSec) / 60.0

        // ptrain = AverageHR / MaxHR
        let ptrain: Double
        if let hr = avgHR, hr > 0 {
            ptrain = min(1.2, max(0.0, Double(hr) / maxHR))  // clamp slightly above 1 just in case
        } else {
            // If we don't have HR yet, treat as "nominal Zone 2":
            // this will be refined once you have proper HK data.
            ptrain = 0.65
        }

        // TRIMP = Ttrain * (e^(k1 * ptrain) - 1) / (e^(k2) - 1)
        let numerator   = exp(k1 * ptrain) - 1.0
        let denominator = exp(k2) - 1.0
        guard denominator > 0 else { return 0 }

        let trimp = Ttrain * (numerator / denominator)
        return max(0, trimp)
    }

    /// Convenience: computes total TRIMP for a collection of ScheduledRun,
    /// using their actual workout data when available.
    ///
    /// For v1:
    /// - If `actual.elapsedSec` is present, we prefer that.
    /// - Otherwise we fall back to the planned `targetDurationSec`.
    ///
    /// - Parameters:
    ///   - runs: The runs (e.g. one week of ScheduledRun).
    ///   - maxHR: User's MHR (e.g., 220 - age) for now passed in manually.
    ///   - gender: TRIMPGender.
    static func totalTRIMP(
        for runs: [ScheduledRun],
        maxHR: Double,
        gender: TRIMPGender
    ) -> Double {
        guard maxHR > 0 else { return 0 }

        return runs.reduce(0.0) { sum, run in
            let durationSec = run.actual.elapsedSec
                ?? run.template.targetDurationSec
                ?? 0
            let avgHR = run.actual.avgHR
            return sum + sessionTRIMP(
                durationSec: durationSec,
                avgHR: avgHR,
                maxHR: maxHR,
                gender: gender
            )
        }
    }

    /// v1 convenience overload: uses a "reasonable" default maxHR and assumes male.
    /// Later, you should remove this and always pass maxHR/gender from UserProfile.
    static func totalTRIMPUsingDefaults(for runs: [ScheduledRun]) -> Double {
        let defaultMaxHR: Double = 200  // temporary until UserProfile is wired
        let defaultGender: TRIMPGender = .male
        return totalTRIMP(for: runs, maxHR: defaultMaxHR, gender: defaultGender)
    }
}
