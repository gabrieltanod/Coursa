//
//  maybGlassEffect.swift
//  Coursa
//
//  Created by Gabriel Tanod on 15/11/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func maybeGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect()
        } else {
            self
        }
    }
}
