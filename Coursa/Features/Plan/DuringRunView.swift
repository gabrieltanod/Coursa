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
                .font(.custom("Helvetica Neue", size: 24))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 40)
            
            Spacer()
                
                Text("Check your watch for real-time\ntracking during your run.")
                    .font(.custom("Helvetica Neue", size: 20))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
            
            Spacer()
            
            Button {
                endRun()
            } label: {
                Text("End run")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.red)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color("black-500").edgesIgnoringSafeArea(.all))
    }
    
    private func endRun() {
        print("iOS: Ending run.")
        // Send stop command to watch
        syncService.sendStopWorkoutCommand()
        dismiss()
    }
}
