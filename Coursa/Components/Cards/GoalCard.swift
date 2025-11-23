//
//  GoalCard.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 19/11/25.
//

import SwiftUI

struct GoalCard: View {
    let run: ScheduledRun
    
    private var maxHeartRate: Double {
        // Load user's age from OnboardingStore and calculate their maxHR
        if let onboardingData = OnboardingStore.load() {
            return TRIMP.maxHeartRate(fromAge: onboardingData.personalInfo.age)
        } else {
            return 190.0  // fallback if no onboarding data
        }
    }
    
    private var calculatedZone: Int {
        let percentage: Double = (Double(run.actual.avgHR ?? 0) / maxHeartRate) * 100
        
        switch percentage {
        case ..<60.0: return 1
        case 60.0..<70.0: return 2
        case 70.0..<80.0: return 3
        case 80.0..<90.0: return 4
        default: return 5
        }
    }
    
    private var zoneInfo: (title: String, caption: AttributedString) {
        switch calculatedZone {
        case 1:
            return ("Goal Achieved!", "Awesome job! You spent most of your run in Zone 1, keeping your effort light and easy. A great base, ease into Zone 2 when you’re ready.")
        case 2:
            return ("Goal Achieved!", "You crushed your distance goal, all while maintaining a steady Zone 2 heart rate. That's fantastic control!")
        case 3:
            return ("You Pushed A Bit Too Hard!", "Distance goal hit! keep an eye on your heart rate next time, it spent a little too much time on Zone 3, pull back the pace a touch.")
        case 4: return ("You Pushed A Bit Too Hard!", "Distance goal hit! keep an eye on your heart rate next time, it spent a little too much time on Zone 4. Your heart works harder and recovery takes longer. Try guiding your effort back toward Zone 2 for safer, steady progress.")
        case 5:
            return ("You Pushed A Bit Too Hard!", "Distance goal hit! keep an eye on your heart rate next time, it spent a little too much time on Zone 5. This zone is very demanding on the heart, shift toward Zone 2 next time to train safely and consistently.")
        default:
            return ("Great Effort, Keep Going!", "Great run today! Get ready, we'll hit the goal next time.")
        }
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            Text("\(zoneInfo.title)")
                .font(.custom("Helvetica Neue", size: 34))
                .bold()
                .foregroundColor(Color("green-500"))
            
            Text("\(zoneInfo.caption)")
                .font(.custom("Helvetica Neue", size: 17))
                .foregroundColor(Color("white-500"))
            
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color("grey-gradient"), location: 0.1566),
                            .init(color: .black,           location: 0.8434)
                        ]),
                        startPoint: .init(x: cos(242 * .pi/180), y: sin(242 * .pi/180)),
                        endPoint:   .init(x: -cos(242 * .pi/180), y: -sin(242 * .pi/180))
                    )
                )
        )
    }
}

