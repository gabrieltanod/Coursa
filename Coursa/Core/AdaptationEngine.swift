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
        lastWeekMinutes: Int
    ) -> Int {
        // Baseline: if nothing last week, seed default
        let baseline = (lastWeekMinutes > 0) ? lastWeekMinutes : WeeklyPlanner.defaultZ2MinutesSeed
        let proposed = Int((Double(baseline) * cap).rounded())
        return max(proposed, WeeklyPlanner.defaultZ2MinutesSeed)
    }
}
