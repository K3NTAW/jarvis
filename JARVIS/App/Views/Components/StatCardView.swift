//
//  StatCardView.swift
//  JARVIS
//
//  Displays a statistic with icon, value, label, and optional subtitle.
//  Glassmorphism style with neon accent glow.
//

import SwiftUI

/// A card displaying a key statistic with icon, value, and label.
struct StatCardView: View {
    let data: BlueprintComponent
    
    @State private var isAppeared = false
    
    private var iconColor: Color {
        JARVISColors.fromHex(data.iconColor) ?? JARVISColors.primaryAccent
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon + Title row
            HStack(spacing: 10) {
                Image(systemName: data.icon ?? "chart.bar")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
                    .glowEffect(color: iconColor, radius: 4)
                
                Text(data.title ?? "Stat")
                    .font(JARVISFonts.caption(14))
                    .foregroundColor(JARVISColors.textSecondary)
                
                Spacer()
            }
            
            // Value
            Text(data.value ?? "—")
                .font(JARVISFonts.stat(28))
                .foregroundColor(JARVISColors.textPrimary)
                .contentTransition(.numericText())
            
            // Subtitle
            if let subtitle = data.subtitle {
                Text(subtitle)
                    .font(JARVISFonts.caption(12))
                    .foregroundColor(JARVISColors.textTertiary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassMorphism()
        .overlay(
            // Left accent bar
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [iconColor.opacity(0.6), iconColor.opacity(0.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 3)
                .padding(.vertical, 8),
            alignment: .leading
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        JARVISColors.background.ignoresSafeArea()
        
        VStack(spacing: 16) {
            StatCardView(data: BlueprintComponent(
                id: "storage",
                type: "stat_card",
                title: "Storage",
                subtitle: "Free of 7.3TB",
                value: "6.7TB",
                icon: "internaldrive",
                iconColor: "#00FFFF"
            ))
            
            StatCardView(data: BlueprintComponent(
                id: "cpu",
                type: "stat_card",
                title: "CPU Usage",
                subtitle: "4 cores active",
                value: "23%",
                icon: "cpu",
                iconColor: "#9D00FF"
            ))
        }
        .padding()
    }
}

