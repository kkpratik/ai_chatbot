//
//  TypingIndicatorView.swift
//  ChatWithAI
//
//  Created by Pratik Parmar on 07/05/26.
//

import SwiftUI

struct TypingIndicatorView: View {
    @State private var isAnimating = false
    var body: some View {
        HStack(spacing: 6) {
            
            dotView(delay: 0.0)
            dotView(delay: 0.2)
            dotView(delay: 0.4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.2))
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    @ViewBuilder
    func dotView(delay: Double) -> some View {
        Circle()
            .fill(Color.purple)
            .frame(width: 6, height: 6)
            .scaleEffect(isAnimating ? 1.3 : 0.7)
            .opacity(isAnimating ? 1.0 : 0.4)
            .animation(
                .easeInOut(duration: 0.6)
                .repeatForever()
                .delay(delay),
                value: isAnimating
            )
    }
}

#Preview {
    TypingIndicatorView()
}
