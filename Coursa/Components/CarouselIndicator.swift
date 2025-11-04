//
//  CarouselIndicator.swift
//  Coursa
//
//  Created by Zikar Nurizky on 27/10/25.
//

import SwiftUI

struct CarouselIndicator: View {
    var currentIndex: Int
    var total: Int = 6

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                Rectangle()
                    .fill(i < currentIndex+1 ?  Color("green-500"): Color("black-400"))
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
                    .clipShape(Capsule(style: .continuous))
            }
        }
        .frame(width: 200, height: 4)
    }
}

#Preview {
    CarouselIndicator(currentIndex: 0)
}
