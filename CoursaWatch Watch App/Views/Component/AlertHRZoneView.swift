//
//  AlertHRZoneView.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 07/11/25.
//

import Foundation
import SwiftUI

struct AlertHRZoneView: View {
    var body: some View {
        VStack{
            Image("icon-heart.fill")
                .resizable()
                .foregroundColor(Color.red)
                .frame(maxWidth: 44, maxHeight: 40)
            
            Text("Above Zone 2!")
                .foregroundColor(Color.red)
                .font(.title3.bold())
            
            Text("Keep your pace around 7:30/km")
                .foregroundColor(Color.white)
                .font(.caption.bold())
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("app"))
        .ignoresSafeArea()
    }
}

#Preview {
    AlertHRZoneView()
}
