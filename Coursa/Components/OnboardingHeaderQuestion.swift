//
//  OnboardingHeaderQuestion.swift
//  Coursa
//
//  Created by Zikar Nurizky on 29/10/25.
//

import SwiftUI

struct OnboardingHeaderQuestion: View {
    var question: String
    var caption: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(question)
                .font(.title2)
                .font(.custom("Helvetica neue", size: 22))
                .fontWeight(.medium)
                .foregroundStyle(Color("white-500"))
                .padding(.bottom, 8)
            
            Text(caption)
                .font(.caption)
                .font(.custom("Helvetica neue", size: 22))
                .fontWeight(.medium)
                .foregroundStyle(Color("white-800"))
        }
    }
}

#Preview {
    OnboardingHeaderQuestion(question: "Which Days You’re Free to Run?", caption: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
}
