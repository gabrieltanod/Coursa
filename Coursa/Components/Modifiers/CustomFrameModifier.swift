//
//  CustomFrameModifier.swift
//  Coursa
//
//  Created by Zikar Nurizky on 29/10/25.
//

import SwiftUI

struct CustomFrameModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color("black-400"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("grey-70"), lineWidth: 1.5)
            )
            .cornerRadius(20)
    }
}

extension View {
    func customFrameModifier() -> some View {
        self.modifier(CustomFrameModifier())
    }
}
