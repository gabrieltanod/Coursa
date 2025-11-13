//
//  ButtonControlView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct ButtonControlView: View {
    @Binding var isRunning: Bool
    var action: () -> Void
    var iconName: String
    var color: String
    var status: String
    
    var body: some View {
        VStack{
            Button(action: action) {
                Image(iconName)
                    .font(.largeTitle)
                    .padding(10)
            }
            .tint(Color(color))
            .padding(10)
            .background(Color(color))
            .frame(maxWidth: 50, maxHeight: 50)
            .cornerRadius(8)
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 8)
            
            Text("\(status)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("primary"))
        }
    }
}

