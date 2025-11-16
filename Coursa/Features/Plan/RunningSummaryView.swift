//
//  RunningSummaryView.swift
//  Coursa
//
//  Created by Zikar Nurizky on 10/11/25.
//

import SwiftUI

struct RunningSummaryView: View {
    var body: some View {
        ScrollView {
            VStack {
                // Masukin value ke RS card yes
                RunningSummaryCard()
                // Masukin value ke HR card yers
                HeartRateCard()
                    .padding(16)
                    //                .cornerRadius(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color("black-450"))
                    )
                
                // Masukin value ke sini jg uers
                PaceResultCard()
                Spacer()
            }
            .padding(24)
        }
        .background(Color("black-500"))
    }
}

#Preview {
    RunningSummaryView()
}
