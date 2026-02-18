//
//  ChatBubbleView.swift
//  JARVIS
//
//  Individual chat bubble for user and JARVIS messages.
//  User: right-aligned, accent color. JARVIS: left-aligned, glass effect.
//

import SwiftUI

/// A single chat message bubble.
struct ChatBubbleView: View {
    let message: Message
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser {
                Spacer(minLength: 60)
            } else {
                // JARVIS avatar
                jarvisAvatar
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Message content
                Text(message.content)
                    .font(JARVISFonts.body(15))
                    .foregroundColor(message.isUser ? .black : JARVISColors.textPrimary)
                    .multilineTextAlignment(message.isUser ? .trailing : .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(bubbleBackground)
                
                // Timestamp
                Text(message.timestamp, style: .time)
                    .font(JARVISFonts.caption(10))
                    .foregroundColor(JARVISColors.textTertiary)
                    .padding(.horizontal, 4)
            }
            
            if !message.isUser {
                Spacer(minLength: 60)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var jarvisAvatar: some View {
        ZStack {
            Circle()
                .fill(JARVISColors.cardBackground)
                .frame(width: 32, height: 32)
            
            Image(systemName: "brain.head.profile")
                .font(.system(size: 16))
                .foregroundColor(JARVISColors.primaryAccent)
        }
        .glowEffect(color: JARVISColors.primaryAccent, radius: 3)
    }
    
    @ViewBuilder
    private var bubbleBackground: some View {
        if message.isUser {
            // User bubble: solid cyan accent
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [JARVISColors.primaryAccent, JARVISColors.primaryAccent.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        } else {
            // JARVIS bubble: glassmorphism
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(JARVISColors.cardBackground.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
        }
    }
}

// MARK: - Typing Indicator

/// An animated typing indicator showing JARVIS is thinking.
struct TypingIndicator: View {
    @State private var dotOffset: [CGFloat] = [0, 0, 0]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            // JARVIS avatar
            ZStack {
                Circle()
                    .fill(JARVISColors.cardBackground)
                    .frame(width: 32, height: 32)
                
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 16))
                    .foregroundColor(JARVISColors.primaryAccent)
            }
            .glowEffect(color: JARVISColors.primaryAccent, radius: 3)
            
            // Typing dots
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(JARVISColors.primaryAccent.opacity(0.6))
                        .frame(width: 7, height: 7)
                        .offset(y: dotOffset[index])
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(JARVISColors.cardBackground.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
            )
            
            Spacer()
        }
        .onAppear { startAnimation() }
    }
    
    private func startAnimation() {
        for i in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.4)
                .repeatForever(autoreverses: true)
                .delay(Double(i) * 0.15)
            ) {
                dotOffset[i] = -6
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        JARVISColors.background.ignoresSafeArea()
        
        VStack(spacing: 12) {
            ChatBubbleView(message: Message(
                content: "Hey JARVIS, how's the server?",
                isUser: true
            ))
            
            ChatBubbleView(message: Message(
                content: "Good morning, Sir! All systems are operational. Server uptime is 99.97% this month.",
                isUser: false
            ))
            
            TypingIndicator()
        }
        .padding()
    }
}

