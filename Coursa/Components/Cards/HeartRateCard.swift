//
//  HeartRateCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 11/11/25.
//

import SwiftUI

struct HeartRateCard: View {
    var avgHR: Int = 130
    
    
    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment:.leading){
                Text("Avg Heart Rate")
                    .font(Font.custom("Helvetica Neue", size: 15))
                    .fontWeight(.regular)
                    .foregroundStyle(Color("white-500"))
                Text("\(avgHR) bpm")
                    .font(Font.custom("Helvetica Neue", size: 28))
                    .fontWeight(.bold)
                    .foregroundStyle(Color("green-500"))
            }
            .padding(.bottom, 12)
            
            VStack (alignment: .leading){
                Text("Heart rate zone")
                    .font(.custom("Helvetica Neue", size: 15))
                    .fontWeight(.regular)
                    .foregroundStyle(Color("white-500"))
                // Masukin value ke zone bar views yes
                ZoneBarsView()
                
            }
        }
    }
}

#Preview {
    HeartRateCard()
}
