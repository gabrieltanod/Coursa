//
//  HeartRateView.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct SummaryHRView: View {
    // Data dummy (dalam detik)
    let zoneTimesInSeconds: [Double] = [272, 932, 152, 0, 0] // 4:32, 15:32, 2:32, 0, 0
    
    private var maxTime: Double {
        return zoneTimesInSeconds.max() ?? 1.0
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                MetricValueView(value: "130", unit: "BPM",color: "secondary")
                MetricLabelView(topText: "Average", bottomText: "HR")
            }
            
            // GeometryReader PENTING untuk mendapatkan lebar maksimal
            GeometryReader { geometry in
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0..<5, id: \.self) { index in
                        
                        ZoneBarView(
                            zoneNumber: index + 1,
                            timeInSeconds: zoneTimesInSeconds[index],
                            maxTimeInSeconds: maxTime,
                            maxWidth: geometry.size.width // Kirim lebar penuh
                        )
                    }
                    
                    Spacer() // Mendorong bar ke atas
                }
            }
            
            
            
        }
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color("app"))
        .ignoresSafeArea(edges: .bottom)
    }
}


#Preview {
    SummaryHRView()
}
