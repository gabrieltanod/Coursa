//
//  TestView.swift
//  Coursa
//
//  Created by Zikar Nurizky on 11/11/25.
//

import SwiftUI

struct TestView: View {
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title in content
                Text("Easy Run")
                    .font(.largeTitle)
                    .bold()

                Text("Wed, Oct 25 2025 at 6:00 AM")
                    .font(.caption)
                    .foregroundColor(.gray)

                // Your content here...
                ForEach(0..<20) { i in
                    Text("Content \(i)")
                        .padding()
                }
            }
            .padding()
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scrollView")).minY
                        )
                }
            )
        }
        .coordinateSpace(name: "scrollView")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Easy Run")
                    .font(.headline)
                    .opacity(scrollOffset < -50 ? 1 : 0)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    TestView()
}
