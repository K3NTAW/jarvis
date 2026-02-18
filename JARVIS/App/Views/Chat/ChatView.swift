//
//  ChatView.swift
//  JARVIS
//
//  Main chat interface for iPhone.
//  Combines message list, blueprint canvas, voice input, and text input.
//

import SwiftUI

/// Main chat view — messages + inline blueprint rendering + input bar.
struct ChatView: View {
    @ObservedObject var service: OpenClawService
    @StateObject private var voiceService = VoiceService()
    @State private var messageText = ""
    @State private var scrollToBottom = false
    
    var body: some View {
        ZStack {
            JARVISColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                JARVISHeader()
                
                // Messages area
                messagesScrollView
                
                // Input bar
                VoiceInputBar(
                    text: $messageText,
                    voiceService: voiceService,
                    onSend: sendMessage
                )
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Messages
    
    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(service.messages) { message in
                        VStack(spacing: 8) {
                            // Chat bubble for text content
                            if !message.content.isEmpty {
                                ChatBubbleView(message: message)
                            }
                            
                            // Blueprint canvas (if message contains a blueprint)
                            if let blueprint = message.blueprint {
                                DynamicCanvasView(blueprint: blueprint)
                                    .padding(.horizontal, 4)
                            }
                        }
                        .id(message.id)
                    }
                    
                    // Typing indicator
                    if service.isLoading {
                        TypingIndicator()
                            .id("typing")
                    }
                    
                    // Bottom spacer for scroll
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: service.messages.count) { _, _ in
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
            .onChange(of: service.isLoading) { _, isLoading in
                if isLoading {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messageText = ""
        
        Task {
            await service.sendMessage(text)
        }
    }
}

// MARK: - JARVIS Header

/// Top header bar with JARVIS branding and connection status.
struct JARVISHeader: View {
    @State private var glowPulse = false
    
    var body: some View {
        HStack {
            // JARVIS logo / name
            HStack(spacing: 10) {
                // Animated arc reactor icon
                ZStack {
                    Circle()
                        .stroke(JARVISColors.primaryAccent.opacity(0.3), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    Circle()
                        .fill(JARVISColors.primaryAccent)
                        .frame(width: 10, height: 10)
                        .shadow(color: JARVISColors.primaryAccent.opacity(glowPulse ? 0.8 : 0.3), radius: glowPulse ? 8 : 3)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        glowPulse = true
                    }
                }
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("J.A.R.V.I.S.")
                        .font(JARVISFonts.title(18))
                        .foregroundColor(JARVISColors.textPrimary)
                    
                    Text("Just A Rather Very Intelligent System")
                        .font(JARVISFonts.caption(9))
                        .foregroundColor(JARVISColors.textTertiary)
                }
            }
            
            Spacer()
            
            // Settings / Status
            Menu {
                Button("Demo Dashboard") {
                    // Will be wired up through the service
                }
                Button("Clear Chat") {
                    // Clear action
                }
                Button("Settings") {
                    // Settings action
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20))
                    .foregroundColor(JARVISColors.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            JARVISColors.background.opacity(0.95)
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            JARVISColors.primaryAccent.opacity(0),
                            JARVISColors.primaryAccent.opacity(0.15),
                            JARVISColors.primaryAccent.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
        }
    }
}

// MARK: - Preview

#Preview {
    ChatView(service: {
        let service = OpenClawService()
        return service
    }())
}

