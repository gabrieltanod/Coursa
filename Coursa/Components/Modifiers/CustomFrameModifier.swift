//
//  CustomFrameModifier.swift
//  Coursa
//
//  Created by Zikar Nurizky on 29/10/25.
//

import SwiftUI

struct CustomFrameModifier: ViewModifier {
    var isActivePage: Bool  // true only on the specified page
    var isSelected: Bool  // true if this button is selected on that page

    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                (isActivePage && isSelected)
                    ? Color("black-300")  // selected button background on active page
                    : Color("black-450")  // default background
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("grey-70"), lineWidth: 1.5)
            )
            .cornerRadius(20)
    }
}
struct CustomChipModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .cornerRadius(20)
            .background(Color("black-400"))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("grey-70"), lineWidth: 1.5)
            )
            .cornerRadius(20)
    }
}

extension View {
    func customFrameModifier(isActivePage: Bool, isSelected: Bool) -> some View
    {
        self.modifier(
            CustomFrameModifier(
                isActivePage: isActivePage,
                isSelected: isSelected
            )
        )
    }

    func customChipModifier() -> some View {
        self.modifier(CustomChipModifier())
    }
}
