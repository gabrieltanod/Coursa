//
//  SummaryTimeDistanceView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct SummaryTimeDistanceView: View {
    @StateObject var viewModel: SummaryPageViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            Text("Time")
                .font(.helveticaNeue(size: 16))
                .foregroundColor(Color("primary"))
                .padding(.top, 8)
            
            Text(viewModel.formattedTotalTime)
                .font(.helveticaNeue(size: 30, weight: .bold))
                .foregroundColor(Color("primary"))
                .padding(.bottom, 8)
            
            Text("Distance")
                .font(.helveticaNeue(size: 16))
                .foregroundColor(Color("primary"))
            
            Text("\(viewModel.formattedTotalDistance) KM")
                .font(.helveticaNeue(size: 30, weight: .bold))
                .foregroundColor(Color("primary"))
        }
        .padding(.horizontal, 15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color("app"))
    }
}
