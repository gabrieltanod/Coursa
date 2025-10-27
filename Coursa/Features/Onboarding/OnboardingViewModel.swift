import Foundation
import SwiftUI
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var step: OnboardingStep = .goals
    @Published var data = OnboardingData()
    
    private let steps: [OnboardingStep] = [
        .goals,
        .personalInfo,
        .daysPerWeek,
        .whichDays,
        .personalBest,
        .recommendedPlan,
        .choosePlan,
        .chooseStartDate,
        .home
    ]
    var index: Int {
        steps.firstIndex(of: step) ?? 0
    }
    
    // MARK: - Navigation Methods
    
    func next() {
        guard let currentIndex = steps.firstIndex(of: step),
              currentIndex < steps.count - 1 else { return }
        
        step = steps[currentIndex + 1]
    }
    
    func back() {
        guard let currentIndex = steps.firstIndex(of: step),
              currentIndex > 0 else { return }
        
        step = steps[currentIndex - 1]
    }
    
    var canGoBack: Bool {
        return steps.firstIndex(of: step) ?? 0 > 0
    }
    
    var isLastStep: Bool {
        return step == .home
    }
    
    // MARK: - Data Update Methods
    
    func setGoal(_ goal: Goal) {
        data.goal = goal
    }
    
    func setPersonalInfo(_ personalInfo: PersonalInfo) {
        data.personalInfo = personalInfo
    }
    
    func setDaysPerWeek(_ days: Int) {
        data.trainingPrefs.daysPerWeek = days
    }
    
    func setSelectedDays(_ days: Set<Int>) {
        data.trainingPrefs.selectedDays = days
    }
    
    func setPersonalBest(distanceKm: Double?, durationText: String?) {
        if let distanceKm = distanceKm {
            data.personalBest.distanceKm = distanceKm
        }
        if let durationText = durationText {
            data.personalBest.durationSeconds = parseHMS(durationText)
        }
    }
    
    func setSelectedPlan(_ plan: Plan) {
        data.selectedPlan = plan
    }
    
    func setStartDate(_ date: Date) {
        data.startDate = date
    }
    
    // MARK: - Plan Recommendation
    
    func recommendPlan() -> Plan {
        guard let goal = data.goal else { return .baseBuilder }
        
        switch goal {
        case .runConsistently:
            return .baseBuilder
        case .improve5K:
            return .fiveKTimeTrial
        case .improve10K:
            return .tenKImprover
        case .halfMarathon:
            return .tenKImprover // Placeholder as requested
        }
    }
    
    func updateRecommendedPlan() {
        data.recommendedPlan = recommendPlan()
    }
    
    // MARK: - Helper Methods
    
    func parseHMS(_ timeString: String) -> Int {
        let components = timeString.split(separator: ":").compactMap { Int($0) }
        
        switch components.count {
        case 3: // hh:mm:ss
            return components[0] * 3600 + components[1] * 60 + components[2]
        case 2: // mm:ss
            return components[0] * 60 + components[1]
        case 1: // ss
            return components[0]
        default:
            return 0
        }
    }
    
    func formatHMS(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}
