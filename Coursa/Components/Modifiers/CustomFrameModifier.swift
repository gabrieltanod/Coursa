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
            .padding(.horizontal, 16)
            .padding(.vertical, 21)
            .background(
                (isActivePage && isSelected)
                    ? Color("black-300")  // selected button background on active page
                    : Color("black-450")  // default background
            )
            .cornerRadius(20)
    }
}
struct CustomChipModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 21)
            .cornerRadius(20)
            .background(Color("black-400"))
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
