//
//  HeartRateCard.swift
//  Coursa
//
//  Created by Zikar Nurizky on 11/11/25.
//

import SwiftUI

struct HeartRateCard: View {
    
    let run : ScheduledRun
    
    @State private var showingInfoHrZone = false
    
    var body: some View {
        
        VStack (alignment: .leading){
            VStack (alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 5) {
                    Text("Heart rate zone")
                        .font(.custom("Helvetica Neue", size: 20, relativeTo: .title3))
                        .fontWeight(.regular)
                        .foregroundStyle(Color("white-500"))
                    
                    Button {
                        showingInfoHrZone.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.custom("Helvetica Neue", size: 16, relativeTo: .body))
                            .foregroundColor(.white)
                    }
                }
                
                Text("See how much time you spent in each heart rate zone during your run.")
                    .font(Font.custom("Helvetica Neue", size: 15, relativeTo: .subheadline))
                    .fontWeight(.regular)
                    .foregroundStyle(Color("black-200"))
                
                ZoneBarsView(run: run)
            }
            
        }
        .sheet(isPresented: $showingInfoHrZone) {
            HeartRateZoneSheetView()
                .presentationDetents([.fraction(1.0)])
        }
        
    }
}

