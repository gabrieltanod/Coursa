//
//  PlanViewModel.swift
//  Coursa
//
//  Created by Gabriel Tanod on 24/10/25.
//

import Foundation
import Combine

@MainActor
final class PlanViewModel: ObservableObject {
    @Published var data = OnboardingData()
    @Published var recommendedPlan: Plan?
    @Published var generatedPlan: GeneratedPlan?
    
    init(data: OnboardingData) {
            self.data = data
        }

    func computeRecommendation() {
        recommendedPlan = PlanLibrary.recommend(for: data)
        data.recommendedPlan = recommendedPlan
    }

    func generatePlan() {
        guard let generated = PlanMapper.generatePlan(from: data) else { return }
        generatedPlan = generated
    }
}
