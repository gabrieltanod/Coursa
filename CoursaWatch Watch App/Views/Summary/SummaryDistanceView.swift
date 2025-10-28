//
//  HeartRateView.swift
//  TestCoursa
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct SummaryDistanceView: View {
    var body: some View {
        VStack(spacing: 8){
            Text("Workout Done!")
                .font(.system(size: 16, weight: .semibold))
            
            ZStack {
                Circle()
                    .fill(Color("success"))
                    .frame(width: 108, height: 108)
                
                Text("3KM")
                    .foregroundColor(Color("secondary"))
                    .font(.system(size: 32, weight: .semibold))
            }
            
            Text("21:15,29")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: 142, maxHeight: 38)
                .background(Color.gray)
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("app"))
        .ignoresSafeArea()
    }
}


#Preview {
    SummaryDistanceView()
}
