//
//  DuringRunView.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 19/11/25.
//

import SwiftUI

struct DuringRunView: View {
    @ObservedObject var syncService: SyncService
    var plan: RunningPlan?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text(plan?.name ?? "Run Session")
                .font(.custom("Helvetica Neue", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 21)
            
            Spacer()
                
                Text("Check your watch for real-time\ntracking during your run.")
                    .font(.custom("Helvetica Neue", size: 17))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            
            Spacer()
            
            Button {
                endRun()
            } label: {
                Text("End Run")
                    .font(.custom("Helvetica Neue", size: 17))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.red)
                    .cornerRadius(20)
            }
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 24)
        .background(Color("black-500"))
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func endRun() {
        print("iOS: Ending run.")
        // Send stop command to watch
        syncService.sendStopWorkoutCommand()
        dismiss()
    }
}
