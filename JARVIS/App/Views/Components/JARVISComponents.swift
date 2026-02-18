//
//  JARVISComponents.swift
//  JARVIS
//
//  Reusable utility components: TextBlock, ListItem, Header, Divider, Button.
//  These are the "smaller" blueprint components that can compose into larger layouts.
//

import SwiftUI

// MARK: - Text Block View

/// Rich text block component with configurable style and alignment.
struct TextBlockView: View {
    let data: BlueprintComponent
    
    private var textAlignment: TextAlignment {
        switch data.alignment {
        case "center": return .center
        case "trailing", "right": return .trailing
        default: return .leading
        }
    }
    
    private var horizontalAlignment: HorizontalAlignment {
        switch data.alignment {
        case "center": return .center
        case "trailing", "right": return .trailing
        default: return .leading
        }
    }
    
    private var textFont: Font {
        switch data.textStyle {
        case "headline": return JARVISFonts.headline()
        case "title": return JARVISFonts.title()
        case "caption": return JARVISFonts.caption()
        case "mono": return JARVISFonts.mono()
        case "stat": return JARVISFonts.stat()
        default: return JARVISFonts.body()
        }
    }
    
    var body: some View {
        VStack(alignment: horizontalAlignment) {
            Text(data.text ?? data.title ?? "")
                .font(textFont)
                .foregroundColor(
                    JARVISColors.fromHex(data.color) ?? JARVISColors.textPrimary
                )
                .multilineTextAlignment(textAlignment)
        }
        .frame(maxWidth: .infinity, alignment: Alignment(horizontal: horizontalAlignment, vertical: .center))
        .padding(.vertical, 4)
    }
}

// MARK: - List Item View

/// A tappable list row with icon, title, subtitle, and chevron.
struct ListItemView: View {
    let data: BlueprintComponent
    
    var body: some View {
        HStack(spacing: 12) {
            // Leading icon
            if let icon = data.icon {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(
                        JARVISColors.fromHex(data.iconColor) ?? JARVISColors.primaryAccent
                    )
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(JARVISColors.cardBackground)
                    )
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 3) {
                Text(data.title ?? "Item")
                    .font(JARVISFonts.body(15))
                    .foregroundColor(JARVISColors.textPrimary)
                
                if let subtitle = data.subtitle {
                    Text(subtitle)
                        .font(JARVISFonts.caption(12))
                        .foregroundColor(JARVISColors.textTertiary)
                }
            }
            
            Spacer()
            
            // Trailing value or chevron
            if let value = data.value {
                Text(value)
                    .font(JARVISFonts.mono(14))
                    .foregroundColor(JARVISColors.primaryAccent)
            }
            
            if data.action != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(JARVISColors.textTertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(JARVISColors.cardBackground.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(JARVISColors.divider.opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Header View

/// Section header with title and optional subtitle.
struct HeaderView: View {
    let data: BlueprintComponent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(data.title ?? "Section")
                .font(JARVISFonts.title(20))
                .foregroundColor(JARVISColors.textPrimary)
            
            if let subtitle = data.subtitle {
                Text(subtitle)
                    .font(JARVISFonts.caption(13))
                    .foregroundColor(JARVISColors.textTertiary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

// MARK: - Divider View

/// Visual separator line.
struct DividerView: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        JARVISColors.divider.opacity(0),
                        JARVISColors.primaryAccent.opacity(0.3),
                        JARVISColors.divider.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .padding(.vertical, 8)
    }
}

// MARK: - Blueprint Button View

/// An action button with icon and title, styled for the JARVIS interface.
struct BlueprintButtonView: View {
    let data: BlueprintComponent
    
    @State private var isPressed = false
    
    private var buttonColor: Color {
        if data.destructive == true {
            return JARVISColors.error
        }
        return JARVISColors.fromHex(data.color) ?? JARVISColors.primaryAccent
    }
    
    private var isFilled: Bool {
        data.buttonStyle == "filled" || data.buttonStyle == nil
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3)) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 8) {
                if let icon = data.icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(data.title ?? "Action")
                    .font(JARVISFonts.body(15))
                    .fontWeight(.semibold)
            }
            .foregroundColor(isFilled ? .black : buttonColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isFilled ? buttonColor : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(buttonColor, lineWidth: isFilled ? 0 : 1.5)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: buttonColor.opacity(0.3), radius: isPressed ? 2 : 6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Text Block") {
    ZStack {
        JARVISColors.background.ignoresSafeArea()
        VStack(spacing: 16) {
            TextBlockView(data: BlueprintComponent(
                type: "text_block",
                text: "Hello, Sir. All systems operational.",
                textStyle: "headline"
            ))
            TextBlockView(data: BlueprintComponent(
                type: "text_block",
                text: "Monitoring 4 services across 2 servers.",
                textStyle: "body"
            ))
        }
        .padding()
    }
}

#Preview("List Items") {
    ZStack {
        JARVISColors.background.ignoresSafeArea()
        VStack(spacing: 8) {
            ListItemView(data: BlueprintComponent(
                type: "list_item",
                title: "Network Settings",
                subtitle: "Configure VPN and DNS",
                icon: "network",
                iconColor: "#00FFFF",
                action: "open_network"
            ))
            ListItemView(data: BlueprintComponent(
                type: "list_item",
                title: "Storage",
                value: "6.7TB free",
                icon: "internaldrive",
                iconColor: "#9D00FF"
            ))
        }
        .padding()
    }
}

#Preview("Buttons") {
    ZStack {
        JARVISColors.background.ignoresSafeArea()
        VStack(spacing: 16) {
            BlueprintButtonView(data: BlueprintComponent(
                type: "button",
                title: "Restart Server",
                icon: "arrow.clockwise"
            ))
            BlueprintButtonView(data: BlueprintComponent(
                type: "button",
                title: "Shutdown",
                icon: "power",
                destructive: true
            ))
            BlueprintButtonView(data: BlueprintComponent(
                type: "button",
                title: "View Logs",
                icon: "doc.text",
                buttonStyle: "outline"
            ))
        }
        .padding()
    }
}

