//
//  ZoneBarView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 28/10/25.
//

import SwiftUI

struct ZoneBarSummaryView: View {
    let zone: Int
    let time: String
    let percentage: Double
    let isMaxZone: Bool
    
    private var zoneColor: Color {
        if isMaxZone {
            return Color("secondary")
        }
        
        switch zone {
        case 1...3:
            return Color("accent")
        case 4...5:
            return Color("accentSecondary")
        default:
            return Color.gray
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                HStack(spacing: 6) {
                    Text("Zone \(zone)")
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(time)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 10)
                .frame(width: max(20, geometry.size.width * (percentage / 100)))
                .frame(height: 30)
                .background(zoneColor)
                .cornerRadius(8)
                
                Spacer(minLength: 0)
            }
        }
        .frame(height: 30)
    }
}
