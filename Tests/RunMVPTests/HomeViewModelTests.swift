import XCTest
@testable import Coursa

final class HomeViewModelTests: XCTestCase {
    
    func testOnboardingViewModelStepTransitions() throws {
        let viewModel = OnboardingViewModel()
        
        // Test initial state
        XCTAssertEqual(viewModel.step, .goals)
        
        // Test next() transitions
        viewModel.next()
        XCTAssertEqual(viewModel.step, .personalInfo)
        
        viewModel.next()
        XCTAssertEqual(viewModel.step, .daysPerWeek)
        
        viewModel.next()
        XCTAssertEqual(viewModel.step, .whichDays)
        
        viewModel.next()
        XCTAssertEqual(viewModel.step, .personalBest)
        
        viewModel.next()
        XCTAssertEqual(viewModel.step, .recommendedPlan)
        
        viewModel.next()
        XCTAssertEqual(viewModel.step, .choosePlan)
        
        viewModel.next()
        XCTAssertEqual(viewModel.step, .chooseStartDate)
        
        viewModel.next()
        XCTAssertEqual(viewModel.step, .home)
    }
    
    func testOnboardingViewModelBackNavigation() throws {
        let viewModel = OnboardingViewModel()
        
        // Move to a middle step
        viewModel.next()
        viewModel.next()
        viewModel.next()
        XCTAssertEqual(viewModel.step, .whichDays)
        
        // Test back navigation
        viewModel.back()
        XCTAssertEqual(viewModel.step, .daysPerWeek)
        
        viewModel.back()
        XCTAssertEqual(viewModel.step, .personalInfo)
        
        viewModel.back()
        XCTAssertEqual(viewModel.step, .goals)
        
        // Test that back doesn't go beyond first step
        viewModel.back()
        XCTAssertEqual(viewModel.step, .goals)
    }
    
    func testOnboardingViewModelCanGoBack() throws {
        let viewModel = OnboardingViewModel()
        
        // First step should not allow going back
        XCTAssertFalse(viewModel.canGoBack)
        
        // After moving forward, should allow going back
        viewModel.next()
        XCTAssertTrue(viewModel.canGoBack)
    }
    
    func testPlanRecommendation() throws {
        let viewModel = OnboardingViewModel()
        
        // Test runConsistently goal
        viewModel.setGoal(.runConsistently)
        let recommendedPlan1 = viewModel.recommendPlan()
        XCTAssertEqual(recommendedPlan1, .baseBuilder)
        
        // Test improve5K goal
        viewModel.setGoal(.improve5K)
        let recommendedPlan2 = viewModel.recommendPlan()
        XCTAssertEqual(recommendedPlan2, .fiveKTimeTrial)
        
        // Test improve10K goal
        viewModel.setGoal(.improve10K)
        let recommendedPlan3 = viewModel.recommendPlan()
        XCTAssertEqual(recommendedPlan3, .tenKImprover)
        
        // Test halfMarathon goal
        viewModel.setGoal(.halfMarathon)
        let recommendedPlan4 = viewModel.recommendPlan()
        XCTAssertEqual(recommendedPlan4, .tenKImprover) // Placeholder as requested
    }
    
    func testParseHMS() throws {
        let viewModel = OnboardingViewModel()
        
        // Test hh:mm:ss format
        XCTAssertEqual(viewModel.parseHMS("01:30:45"), 5445) // 1*3600 + 30*60 + 45
        
        // Test mm:ss format
        XCTAssertEqual(viewModel.parseHMS("30:45"), 1845) // 30*60 + 45
        
        // Test ss format
        XCTAssertEqual(viewModel.parseHMS("45"), 45)
        
        // Test invalid format
        XCTAssertEqual(viewModel.parseHMS("invalid"), 0)
    }
}

