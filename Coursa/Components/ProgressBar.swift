//
//  ProgressBar.swift
//  Coursa
//
//  Created by Zikar Nurizky on 11/11/25.
//

import SwiftUI

struct ProgressBar: View {
    var value: Double
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color("black-400").opacity(0.22))
                    .frame(width: max(0, min(value, 1)) * 360, height: 37) // Set fixed width for background
                
                Capsule()
                    .fill(Color("green-500"))
                    .frame(width: max(0, min(value, 1)) * 360, height: 37)
                    .animation(.easeInOut(duration: 0.35), value: value)
                
            }
        }
    }
}

#Preview {
    ProgressBar(value: 0.3)
}
