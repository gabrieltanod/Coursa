//
//  TextIconView.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 19/11/25.
//

import SwiftUI

struct TextIconView: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack (spacing: 12) {
            Image("\(icon)")
                .font(.system(size: 24))
//                .foregroundColor(Color("green-500"))
            
            Text(text)
                .font(.custom("Helvetica Neue", size: 16))
                .foregroundColor(Color.white)
        }
    }
}

