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
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color("black-475"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .inset(by: 0.5)
                .stroke(Color(red: 0.25, green: 0.25, blue: 0.25), lineWidth: 1)
        )
    }
}
