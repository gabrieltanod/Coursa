//
//  HeartRateView.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct HeartRateView: View {
    
    private let headerHeight: CGFloat = 105
    
    var body: some View {
        
        VStack(alignment: .leading) {
            // Detak Jantung (125 BPM + Heart Badge)
            Spacer(minLength: headerHeight)
            HStack(spacing: 2) {
                HStack {
                    Text("1")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color("secondary"))
                .cornerRadius(8)
                
                HStack {
                    Text("Zone 2")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color("secondary")) // Warna hijau neon/kuning terang kustom
                .cornerRadius(8)
                
                HStack {
                    Text("3")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color("secondary")) // Warna hijau neon/kuning terang kustom
                .cornerRadius(8)
                
                HStack {
                    Text("4")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color("secondary")) // Warna hijau neon/kuning terang kustom
                .cornerRadius(8)
                
                HStack {
                    Text("5")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color("secondary")) // Warna hijau neon/kuning terang kustom
                .cornerRadius(8)
            }
            
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: "333", unit: "BPM", color: "primary")
                MetricLabelView(topText: "CUR", bottomText: "HR")
            }
            
            HStack(alignment: .lastTextBaseline) {
                MetricValueView(value: "333", unit: "BPM", color: "primary")
                MetricLabelView(topText: "AVG", bottomText: "HR")
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .ignoresSafeArea()
        .background(Color("app"))
    }
}


#Preview {
    HeartRateView()
}
