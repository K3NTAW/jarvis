//
//  ProgressRingView.swift
//  JARVIS
//
//  Circular progress indicator with animated fill.
//  Shows percentage, label, and customizable accent color.
//

import SwiftUI

/// A circular progress ring with label and value.
struct ProgressRingView: View {
    let data: BlueprintComponent
    
    @State private var animatedProgress: Double = 0
    
    private var targetProgress: Double {
        data.progressValue ?? data.progress ?? 0
    }
    
    private var ringColor: Color {
        JARVISColors.fromHex(data.color) ?? JARVISColors.primaryAccent
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        JARVISColors.cardBackgroundLight,
                        lineWidth: 8
                    )
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        AngularGradient(
                            colors: [ringColor.opacity(0.3), ringColor],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360 * animatedProgress)
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: ringColor.opacity(0.5), radius: 4)
                
                // Center text
                VStack(spacing: 2) {
                    Text(data.value ?? "\(Int(targetProgress * 100))%")
                        .font(JARVISFonts.stat(22))
                        .foregroundColor(JARVISColors.textPrimary)
                    
                    if let label = data.label ?? data.title {
                        Text(label)
                            .font(JARVISFonts.caption(10))
                            .foregroundColor(JARVISColors.textTertiary)
                    }
                }
            }
            .frame(width: 100, height: 100)
            
            if let subtitle = data.subtitle {
                Text(subtitle)
                    .font(JARVISFonts.caption(12))
                    .foregroundColor(JARVISColors.textSecondary)
            }
        }
        .padding(16)
        .glassMorphism()
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animatedProgress = targetProgress
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        JARVISColors.background.ignoresSafeArea()
        
        HStack(spacing: 20) {
            ProgressRingView(data: BlueprintComponent(
                id: "disk",
                type: "progress_ring",
                title: "Disk",
                value: "67%",
                progressValue: 0.67,
                color: "#00FFFF"
            ))
            
            ProgressRingView(data: BlueprintComponent(
                id: "cpu",
                type: "progress_ring",
                title: "CPU",
                value: "23%",
                progressValue: 0.23,
                color: "#9D00FF"
            ))
        }
        .padding()
    }
}

