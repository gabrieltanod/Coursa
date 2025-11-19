import SwiftUI

struct RunningNotesModalView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Text("Conversational Pace")
                    .font(.custom("Helvetica Neue", size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 28)
                
                Text("Conversational pace is a running term that denotes an easy, low-intensity speed at which you can talk comfortably in full sentences without getting out of breath. It sits in the aerobic zone, typically Zone 2 for most runners.")
                    .font(.custom("Helvetica Neue", size: 17))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .presentationDetents([.medium])
    }
}
