import Foundation

// MARK: - Goal Enum
enum Goal: String, CaseIterable, Identifiable, Codable {
    case runConsistently = "Run Consistently"
    case improve5K = "Improve 5K"
    case improve10K = "Improve 10K"
    case halfMarathon = "Half Marathon"
    
    var id: String { rawValue }
}

// MARK: - Personal Info
struct PersonalInfo: Codable {
    var age: Int = 0
    var gender: String = ""
    var weightKg: Double = 0.0
    var heightCm: Double = 0.0
}

// MARK: - Training Preferences
struct TrainingPrefs: Codable {
    var daysPerWeek: Int = 2
    var selectedDays: Set<Int> = [] // Weekday indices (1-7, Sunday = 1)
}

// MARK: - Personal Best
struct PersonalBest: Codable {
    var distanceKm: Double = 0.0
    var durationSeconds: Int = 0 // Total seconds from hh:mm:ss
    
    var durationText: String {
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        let seconds = durationSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - Plan Enum
enum Plan: String, CaseIterable, Identifiable, Codable {
    case baseBuilder = "Base Builder"
    case fiveKTimeTrial = "5K Time Trial"
    case tenKImprover = "10K Improver"
    case halfMarathonPrep = "Half Marathon Prep"
    
    var id: String { rawValue }
}

// MARK: - Onboarding Data
struct OnboardingData: Codable {
    var goal: Goal?
    var personalInfo = PersonalInfo()
    var trainingPrefs = TrainingPrefs()
    var personalBest = PersonalBest()
    var recommendedPlan: Plan?
    var selectedPlan: Plan?
    var startDate = Date()
    
    var isComplete: Bool {
        return goal != nil &&
               personalInfo.age > 0 &&
               !personalInfo.gender.isEmpty &&
               personalInfo.weightKg > 0 &&
               personalInfo.heightCm > 0 &&
               trainingPrefs.daysPerWeek >= 2 &&
               !trainingPrefs.selectedDays.isEmpty &&
               selectedPlan != nil
    }
}

// MARK: - Onboarding Steps
enum OnboardingStep: String, CaseIterable {
    case goals = "Goals"
    case personalInfo = "Personal Info"
    case daysPerWeek = "Days Per Week"
    case whichDays = "Which Days"
    case personalBest = "Personal Best"
    case recommendedPlan = "Recommended Plan"
    case choosePlan = "Choose Plan"
    case chooseStartDate = "Choose Start Date"
    case home = "Home"
    
    var title: String { rawValue }
}

