//
//  GoalCard.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 19/11/25.
//

import SwiftUI

enum GoalType: String, CaseIterable, Codable {
    case zone1
    case zone2
    case zone3
    case zone4
    case zone5
    case notFinished
    
    var title: String {
        switch self {
        case .zone1, .zone2: return "Goal Achieved!"
        case .zone3, .zone4, .zone5: return "You Pushed A Bit Too Hard!"
        case .notFinished: return "Great Effort, Keep Going!"
        }
    }
    
    var caption: AttributedString {
        switch self {
        case .zone1: return "Awesome job! You spent most of your run in Zone 1, keeping your effort light and easy. A great base, ease into Zone 2 when you’re ready."
        case .zone2: return "You crushed your distance goal, all while maintaining a steady Zone 2 heart rate. That's fantastic control!"
        case .zone3: return "Distance goal hit! keep an eye on your heart rate next time, it spent a little too much time on Zone 3, pull back the pace a touch."
        case .zone4: return "Distance goal hit! keep an eye on your heart rate next time, it spent a little too much time on Zone 4. Your heart works harder and recovery takes longer. Try guiding your effort back toward Zone 2 for safer, steady progress."
        case .zone5: return "Distance goal hit! keep an eye on your heart rate next time, it spent a little too much time on Zone 5. This zone is very demanding on the heart, shift toward Zone 2 next time to train safely and consistently."
        case .notFinished: return "Great run today! Get ready, we'll hit the goal next time."
        }
    }
}

struct GoalCard: View {
    
    let type: GoalType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            Text("\(type.title)")
                .font(.custom("Helvetica Neue", size: 34))
                .bold()
                .foregroundColor(Color("green-500"))
            
            Text("\(type.caption)")
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

#Preview {
    GoalCard(
        type: .zone2
    )
}
