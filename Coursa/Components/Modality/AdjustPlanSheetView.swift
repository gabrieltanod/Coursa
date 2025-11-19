//
//  AdjustPlanSheetView.swift
//  Coursa
//
//  Created by Chairal Octavyanz on 19/11/25.
//

import SwiftUI

struct AdjustPlanSheetView: View {
    var body: some View {
        VStack{
            Text("Finalize Plan")
                .font(.custom("Helvetica Neue", size: 20))
                .foregroundColor(Color.white)
                .padding(32)
            
            Image("CoursaImages/AdjustPlanSheet")
                .resizable()
                .scaledToFit()
                .clipped()
                .overlay(
                    ZStack {
                        LinearGradient(
                            colors: [.clear, Color("black-500")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                )
            
            VStack(alignment: .leading, spacing: 20){
                Text("Endurance Training Plan")
                    .font(.custom("Helvetica Neue", size: 28))
                    .foregroundColor(Color.white)
                    .bold()
                
                VStack(alignment: .leading, spacing: 8){
                    TextIconView(icon: "WeeksIcon", text: "8 Weeks")
                    TextIconView(icon: "Calendar", text: "Tuesday, 20th Oct 2025")
                }
                
                VStack(alignment: .leading, spacing: 16){
                    Text("Your plan is personalized based on these details:")
                        .font(.custom("Helvetica Neue", size: 16))
                    
                    TextIconView(icon: "CheckIcon", text: "Your current running record in 3km is 47:21")
                    TextIconView(icon: "CheckIcon", text: "You are available to run on Mon, Thu, and Sat")
                }
                
                Spacer()
                
                VStack {
                    Button {
                        // TODO: masukin func logic start kalo udah ada di sini
                    } label: {
                        Text("Continue")
                            .font(.custom("Helvetica Neue", size: 17))
                            .foregroundColor(Color.black)
                            .frame(maxWidth: .infinity, minHeight: 54, alignment: .center)
                    }
                    .frame(maxWidth: .infinity, minHeight: 54, alignment: .center)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                    .background(Color("black-500"))
                }
                .frame(maxWidth: .infinity)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .foregroundColor(Color.white)
            
            
        }
        .ignoresSafeArea(edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("black-500"))
    }
}

#Preview {
    AdjustPlanSheetView()
}
