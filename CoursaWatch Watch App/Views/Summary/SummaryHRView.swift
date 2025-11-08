//
//  SummaryHRView.swift
//  WatchTestCoursa Watch App
//
//  Created by Chairal Octavyanz on 25/10/25.
//

import SwiftUI

struct SummaryHRView: View {
    @StateObject var viewModel: SummaryPageViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                MetricValueView(value: viewModel.formattedAverageHR, unit: "BPM",color: "secondary")
                MetricLabelView(topText: "Average", bottomText: "HR")
            }
            
            VStack(spacing: 8) {
                let _ = print("Jumlah data zona: \(viewModel.zoneChartData.count)")
                ForEach(viewModel.zoneChartData, id: \.zone) { data in
                    ZoneBarSummaryView(
                        zone: data.zone,
                        time: data.timeString,
                        percentage: data.percentage,
                        isMaxZone: data.isMax
                    )
                }
            }
        }
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color("app"))
        .ignoresSafeArea(edges: .bottom)
    }
}
