//
//  PlanLibrary.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

import Foundation

enum PlanLibrary {
    static func recommend(for data: OnboardingData) -> Plan {
        guard let goal = data.goal else { return .baseBuilder }

        switch goal {
        case .runConsistently:
            return .baseBuilder
        case .improve5K:
            return .fiveKTimeTrial
        case .improve10K:
            return .tenKImprover
        case .halfMarathon:
            return .halfMarathonPrep
        }
    }
}
