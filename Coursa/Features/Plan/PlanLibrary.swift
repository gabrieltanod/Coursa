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
        case .improveEndurance:
            return .endurance
        case .improveSpeed:
            return .speed
        case .halfMarathon:
            return .halfMarathonPrep
        }
    }
}
