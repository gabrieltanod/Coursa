//
//  PaceResultCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 11/11/25.
//

import SwiftUI

struct PaceResultCard: View {
    var avgPace: String = "00:00"
    var maxPace: String = "00:00"
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Average Pace")
                    .font(.custom("Helvetica Neue", size: 15))
                    .fontWeight(.regular)
                    .foregroundStyle(Color("white-500"))
                Text("\(avgPace)/Km")
                    .font(.custom("Helvetica Neue", size: 28))
                    .fontWeight(.bold)
                    .foregroundStyle(Color("green-500"))
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Max Pace")
                    .font(.custom("Helvetica Neue", size: 15))
                    .fontWeight(.regular)
                    .foregroundStyle(Color("white-500"))
                Text("\(maxPace)/Km")
                    .font(.custom("Helvetica Neue", size: 28))
                    .fontWeight(.bold)
                    .foregroundStyle(Color("green-500"))
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Color("black-450")))
    }
}

#Preview {
    PaceResultCard()
}
