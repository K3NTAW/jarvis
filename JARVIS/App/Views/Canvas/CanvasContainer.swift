//
//  CanvasContainer.swift
//  JARVIS
//
//  Full-screen canvas container for displaying blueprints outside of chat.
//  Used on Apple TV and as a dedicated canvas tab on iPhone.
//

import SwiftUI

/// A full-screen canvas container that displays the current blueprint.
struct CanvasContainer: View {
    @ObservedObject var service: OpenClawService
    
    @State private var showDemoPrompt = true
    
    var body: some View {
        ZStack {
            JARVISColors.background.ignoresSafeArea()
            
            if let blueprint = service.currentBlueprint {
                // Active blueprint
                ScrollView {
                    DynamicCanvasView(blueprint: blueprint)
                        .padding()
                }
            } else {
                // Empty state
                emptyState
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Animated JARVIS icon
            ZStack {
                Circle()
                    .stroke(JARVISColors.primaryAccent.opacity(0.15), lineWidth: 2)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .stroke(JARVISColors.primaryAccent.opacity(0.1), lineWidth: 1)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(JARVISColors.primaryAccent.opacity(0.5))
                    .symbolEffect(.pulse, options: .repeating)
            }
            .floating(amplitude: 5, duration: 3.0)
            
            VStack(spacing: 8) {
                Text("JARVIS Canvas")
                    .font(JARVISFonts.title(22))
                    .foregroundColor(JARVISColors.textPrimary)
                
                Text("Ask JARVIS to show you something and\nthe interface will appear here.")
                    .font(JARVISFonts.body(14))
                    .foregroundColor(JARVISColors.textTertiary)
                    .multilineTextAlignment(.center)
            }
            
            // Demo button
            if showDemoPrompt {
                Button(action: {
                    service.injectDemoBlueprint()
                    showDemoPrompt = false
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                        Text("Load Demo Dashboard")
                    }
                    .font(JARVISFonts.body(14))
                    .foregroundColor(JARVISColors.primaryAccent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .stroke(JARVISColors.primaryAccent.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    CanvasContainer(service: OpenClawService())
}

