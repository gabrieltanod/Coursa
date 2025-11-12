//
//  TRIMP.swift
//  Coursa
//
//  Created by Gabriel Tanod on 12/11/25.
//
//  Summary
//  -------
//  Converts "how long" and "how hard" a session felt into a single
//  training load number. For v1 we keep it minimal and hardcode HRmax.
//
//  Responsibilities
//  ----------------
//  - Compute TRIMP per session from duration + avgHR (or a simple proxy).
//  - Sum TRIMP across a week.
//  - Use a hardcoded HRmax and Zone-2 bounds for now (no user profile yet).
//

import Foundation

enum TRIMP {
    // Hardcoded v1 defaults
    private static let hrMax: Double = 200.0
    private static let z2Lower: Double = 0.60
    private static let z2Upper: Double = 0.70
    private static let z2Mid:   Double = (0.60 + 0.70) / 2.0

    static func sessionTRIMP(durationMin: Double, avgHR: Int?) -> Double {
        let intensity: Double
        if let hr = avgHR, hr > 0 {
            intensity = min(1.0, max(0.0, Double(hr)/hrMax))
        } else {
            intensity = z2Mid // fallback: Zone-2 midpoint
        }
        // Simple v1 model: minutes * intensity scaling
        return durationMin * intensity
    }

    static func totalTRIMP(for runs: [ScheduledRun]) -> Double {
        runs.reduce(0.0) { sum, run in
            let durMin = Double(run.actual.elapsedSec ?? run.template.targetDurationSec ?? 0) / 60.0
            let avgHR  = run.actual.avgHR
            return sum + sessionTRIMP(durationMin: max(0, durMin), avgHR: avgHR)
        }
    }
}
