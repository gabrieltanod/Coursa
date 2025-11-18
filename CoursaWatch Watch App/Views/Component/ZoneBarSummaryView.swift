//
//  ZoneBarsView.swift
//  Coursa
//
//  Created by Zikar Nurizky on 11/11/25.
//

import SwiftUI

struct ZoneBar: View {
    let label: String
    let time: String?
    let width: CGFloat
    let isHighest: Bool
    
    var gradientHighest: LinearGradient {
        LinearGradient(
            colors: [Color("er1"), Color("er2")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: [Color("maf1"), Color("maf2")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.custom("Helvetica Neue", size: 14))
                .foregroundColor(isHighest ? Color("secondary") : .white)
            
            Spacer()
            
            if let time = time {
                Text(time)
                    .font(.custom("Helvetica Neue", size: 14))
                    .foregroundColor(isHighest ? Color("secondary") : .white)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .frame(maxWidth: width, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHighest ? gradientHighest : gradient)
        )
        .animation(.easeInOut(duration: 0.3), value: width)
        .animation(.easeInOut(duration: 0.3), value: isHighest)
    }
}

struct ZoneBarSummaryView: View {
    @ObservedObject var viewModel: SummaryPageViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 12) {
                
                ForEach(viewModel.zoneChartData, id: \.zone) { zone in
                    ZoneBar(
                        label: "Zone \(zone.zone)",
                        time: zone.timeString.isEmpty ? nil : zone.timeString,
                        width: geometry.size.width * CGFloat(zone.percentage / 100),
                        isHighest: zone.isMax
                    )
                }
            }
            .padding(8)
        }
    }
}


#Preview {
    //    ZoneBarSummaryView(zoneDuration: [
    //        1: 272,
    //        2: 6032,
    //        3: 152,
    //        4: 0,
    //        5: 0
    //    ])
    
}
