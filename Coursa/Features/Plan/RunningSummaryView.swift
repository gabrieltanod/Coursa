//
//  RunningSummaryView.swift
//  Coursa
//
//  Created by Zikar Nurizky on 10/11/25.
//

import SwiftUI

struct RunningSummaryView: View {
    var body: some View {
        VStack (spacing: 20){
            RunningSummaryCard()
            HeartRateCard()
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("black-450"))
            )
        }
        .padding(24)
        .background(Color("black-500"))
    }
}

#Preview {
    RunningSummaryView()
}
