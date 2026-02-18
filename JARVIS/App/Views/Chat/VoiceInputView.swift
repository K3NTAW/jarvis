//
//  VoiceInputView.swift
//  JARVIS
//
//  Voice input bar and text input for the chat interface.
//  Combines text field with voice input button and send action.
//

import SwiftUI

/// Input bar at the bottom of the chat — text field + voice + send.
struct VoiceInputBar: View {
    @Binding var text: String
    @ObservedObject var voiceService: VoiceService
    let onSend: () -> Void
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Separator
            Rectangle()
                .fill(JARVISColors.divider.opacity(0.3))
                .frame(height: 0.5)
            
            HStack(spacing: 12) {
                // Voice button
                voiceButton
                
                // Text field
                textField
                
                // Send button
                sendButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(JARVISColors.background.opacity(0.95))
        }
    }
    
    // MARK: - Subviews
    
    private var voiceButton: some View {
        Button(action: {
            voiceService.toggleListening()
        }) {
            ZStack {
                Circle()
                    .fill(voiceService.isListening
                          ? JARVISColors.error.opacity(0.2)
                          : JARVISColors.cardBackground)
                    .frame(width: 40, height: 40)
                
                Image(systemName: voiceService.isListening ? "mic.fill" : "mic")
                    .font(.system(size: 18))
                    .foregroundColor(voiceService.isListening
                                    ? JARVISColors.error
                                    : JARVISColors.primaryAccent)
            }
            .overlay(
                Circle()
                    .stroke(
                        voiceService.isListening
                            ? JARVISColors.error.opacity(0.5)
                            : Color.clear,
                        lineWidth: 2
                    )
                    .scaleEffect(voiceService.isListening ? 1.3 : 1.0)
                    .opacity(voiceService.isListening ? 0.0 : 1.0)
                    .animation(
                        voiceService.isListening
                            ? .easeOut(duration: 1.0).repeatForever(autoreverses: false)
                            : .default,
                        value: voiceService.isListening
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private var textField: some View {
        HStack {
            TextField("Ask JARVIS...", text: $text, axis: .vertical)
                .font(JARVISFonts.body(15))
                .foregroundColor(JARVISColors.textPrimary)
                .lineLimit(1...4)
                .focused($isTextFieldFocused)
                .onSubmit { sendIfNotEmpty() }
                .tint(JARVISColors.primaryAccent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(JARVISColors.inputBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isTextFieldFocused
                        ? JARVISColors.primaryAccent.opacity(0.5)
                        : JARVISColors.divider.opacity(0.3),
                    lineWidth: 0.5
                )
        )
        .onChange(of: voiceService.transcribedText) { _, newValue in
            if !newValue.isEmpty {
                text = newValue
            }
        }
    }
    
    private var sendButton: some View {
        Button(action: sendIfNotEmpty) {
            ZStack {
                Circle()
                    .fill(
                        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? JARVISColors.cardBackground
                            : JARVISColors.primaryAccent
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(
                        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? JARVISColors.textTertiary
                            : .black
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
    
    // MARK: - Actions
    
    private func sendIfNotEmpty() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onSend()
        text = ""
        isTextFieldFocused = false
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        JARVISColors.background.ignoresSafeArea()
        VStack {
            Spacer()
            VoiceInputBar(
                text: .constant(""),
                voiceService: VoiceService(),
                onSend: {}
            )
        }
    }
}

