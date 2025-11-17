//
//  HeartRateCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 11/11/25.
//

import SwiftUI

struct HeartRateCard: View {
    
    let run : ScheduledRun
    private var avgHR: Int? {
        run.actual.avgHR
    }
    
    private var formattedAvgHR: String {
        String("\(run.actual.avgHR ?? 0) bpm")
    }
    
    var body: some View {
        VStack (alignment: .leading){
            Text("Heart Rate")
                .font(Font.custom("Helvetica Neue", size: 15))
                .fontWeight(.regular)
                .foregroundStyle(Color("white-500"))
            
            VStack (alignment: .leading) {
                VStack (alignment:.leading){
                    Text("Average Heart Rate")
                        .font(Font.custom("Helvetica Neue", size: 15))
                        .fontWeight(.regular)
                        .foregroundStyle(Color("white-500"))
                    Text("\(formattedAvgHR)")
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
                    
                    Text("See how much time you spent in each heart rate zone during your run.")
                        .font(Font.custom("Helvetica Neue", size: 15))
                        .fontWeight(.regular)
                        .foregroundStyle(Color("black-200"))
                    
                    // Masukin value ke zone bar views yes
                    ZoneBarsView()
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color("black-450"))
            )

        }
        
    }
}

