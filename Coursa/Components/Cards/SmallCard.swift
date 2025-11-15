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
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: 200, alignment: .topLeading)
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.23, green: 0.23, blue: 0.23), location: 0.00),
                    .init(color: Color(red: 0.18, green: 0.16, blue: 0.17), location: 0.52)
                ],
                startPoint: UnitPoint(x: 0.91, y: 0.11),
                endPoint: UnitPoint(x: 0.28, y: 1.24)
            )
        )
        .cornerRadius(12)
    }
}
