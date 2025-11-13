//
//  AdaptationEngine.swift
//  Coursa
//
//  Created by Gabriel Tanod on 12/11/25.
//
//  Summary
//  -------
//  Decides next week's total work based on last week's load,
//  capped at +10% growth.
//
//  Responsibilities
//  ----------------
//  - Input: last week's TRIMP or total Zone-2 minutes.
//  - Output: next week's Zone-2 minute target.
//  - Apply growth cap (+10%) and 16-week ceiling.
//  - Keep logic simple and deterministic for v1.
//
import Foundation

enum AdaptationEngine {
    // Growth cap +10%
    private static let cap: Double = 1.10

    /// lastWeekTRIMP is accepted for future sophistication; for v1,
    /// if TRIMP is zero/missing we fall back to lastWeekMinutes.
    static func nextWeekMinutes(
        lastWeekTRIMP: Double,
        thisWeekTRIMP: Double,
        lastWeekMinutes: Int,
        runningFrequency: Int
    ) -> Int {

        guard lastWeekMinutes > 0 else {
            return WeeklyPlanner.defaultZ2MinutesSeed
        }

        // 1. Determine overloadFactor based on TRIMP comparisons
        let lowerBound = lastWeekTRIMP * 0.9
        let upperBound = lastWeekTRIMP * 1.2
        let progressLow = lastWeekTRIMP * 1.0
        let progressHigh = lastWeekTRIMP * 1.1

        let overloadFactor: Double

        if thisWeekTRIMP < lowerBound {
            // Under-trained → repeat
            overloadFactor = 1.0
        } else if thisWeekTRIMP > upperBound {
            // Over-reached → repeat
            overloadFactor = 1.0
        } else if thisWeekTRIMP >= progressLow && thisWeekTRIMP <= progressHigh
        {
            // Good progress → +5%
            overloadFactor = 1.05
        } else {
            // Ambiguous → repeat
            overloadFactor = 1.0
        }

        // 2. Compute next week total minutes
        let nextWeekTotal = Double(lastWeekMinutes) * overloadFactor

        // 3. Hard clamps
        let minMinutes = WeeklyPlanner.defaultZ2MinutesSeed
        let maxMinutes = Int(Double(lastWeekMinutes) * 1.10)  // absolute ceiling

        let constrained = max(
            minMinutes,
            min(Int(nextWeekTotal.rounded()), maxMinutes)
        )
        return constrained
    }
}
