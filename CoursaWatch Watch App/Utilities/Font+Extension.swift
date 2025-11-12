//
//  Font+Extension.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 08/11/25.
//

import SwiftUI

extension Font {
    static func helveticaNeue(size: CGFloat, weight: Font.Weight = .regular, style: Font.TextStyle = .body) -> Font {
        let fontName: String
        switch weight {
        case .bold:
            fontName = "HelveticaNeue-Bold"
        case .medium:
            fontName = "HelveticaNeue-Medium"
        case .light:
            fontName = "HelveticaNeue-Light"
        case .semibold:
            fontName = "HelveticaNeue-Semibold"
        // masih kurang case weight lainnya
        default:
            fontName = "HelveticaNeue"
        }
        
        return .custom(fontName, size: size, relativeTo: style)
    }
}
