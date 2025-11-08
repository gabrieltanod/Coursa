//
//  HeartRateView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct SummaryDistanceView: View {
    @StateObject var viewModel: SummaryPageViewModel
    
    var body: some View {
        VStack(spacing: 8){
            Text("Workout Done!")
                .font(.system(size: 16, weight: .semibold))
            
            ZStack {
                Circle()
                    .fill(Color("success"))
                    .frame(width: 108, height: 108)
                
                Text("\(viewModel.formattedTotalDistance) KM")
                    .foregroundColor(Color("secondary"))
                    .font(.system(size: 32, weight: .semibold))
            }
            
            Text(viewModel.formattedTotalTime)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: 142, maxHeight: 38)
                .background(Color.gray)
                .cornerRadius(20)
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("app"))
        .ignoresSafeArea()
    }
}
