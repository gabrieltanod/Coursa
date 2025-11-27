//
//  SummaryCard.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 24/11/25.
//

import SwiftUI

struct SummaryCard: View {
    let message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            Text("Summary")
                .font(.custom("Helvetica Neue", size: 16, relativeTo: .body))
                .fontWeight(.medium)
                .foregroundColor(Color("white-500"))
                .lineLimit(1)
            
            Text(message)
                .font(.custom("Helvetica Neue", size: 15, relativeTo: .body))
                .foregroundColor(Color("white-500"))
                .fixedSize(horizontal: false, vertical: true)
            
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("black-475"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("black-400"), lineWidth: 1)
                )
        )
    }
}

#Preview {
    SummaryCard(
        message: "You’ve increased your pace, but your aerobic time can be better. The first priority is to build your endurance first. Keep up the good work. "
    )
}
