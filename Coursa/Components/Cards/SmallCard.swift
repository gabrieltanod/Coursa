//
//  SmallCard.swift
//  Coursa
//
//  Created by Gabriel Tanod on 14/11/25.
//

import SwiftUI

struct SmallCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: 200, alignment: .topLeading)
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(
                        color: Color(red: 0.11, green: 0.11, blue: 0.11),
                        location: 0.00
                    ),
                    Gradient.Stop(color: .black, location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.76, y: 0),
                endPoint: UnitPoint(x: 0.24, y: 1)
            )
        )
        .cornerRadius(20)
    }
}
