//
//  ComponentRegistry.swift
//  JARVIS
//
//  Maps component type strings to SwiftUI views.
//  The "dumb renderer" — takes a BlueprintComponent and returns the right view.
//

import SwiftUI

/// Registry that maps BlueprintComponent types to their corresponding SwiftUI views.
struct ComponentRegistry {
    
    /// Returns the appropriate SwiftUI view for a given BlueprintComponent.
    @ViewBuilder
    static func view(for component: BlueprintComponent, index: Int = 0) -> some View {
        switch component.type {
        case "stat_card":
            StatCardView(data: component)
                .animatedAppearance(delay: Double(index) * 0.1)
            
        case "status_grid":
            StatusGridView(data: component)
                .animatedAppearance(delay: Double(index) * 0.1)
            
        case "status_row":
            StatusRowView(data: component)
                .animatedAppearance(delay: Double(index) * 0.1)
            
        case "media_thumbnail":
            MediaThumbnailView(data: component)
                .animatedAppearance(delay: Double(index) * 0.1)
            
        case "weather_display":
            WeatherDisplayView(data: component)
                .animatedAppearance(delay: Double(index) * 0.1)
            
        case "progress_ring":
            ProgressRingView(data: component)
                .animatedAppearance(delay: Double(index) * 0.1)
            
        case "chart_bar":
            ChartBarView(data: component)
                .animatedAppearance(delay: Double(index) * 0.1)
            
        case "text_block":
            TextBlockView(data: component)
                .animatedAppearance(delay: Double(index) * 0.1)
            
        case "list_item":
            ListItemView(data: component)
                .animatedAppearance(delay: Double(index) * 0.1)
            
        case "header":
            HeaderView(data: component)
                .animatedAppearance(delay: Double(index) * 0.1)
            
        case "divider":
            DividerView()
                .animatedAppearance(delay: Double(index) * 0.1)
            
        case "button":
            BlueprintButtonView(data: component)
                .animatedAppearance(delay: Double(index) * 0.1)
            
        case "chat_bubble":
            ChatBubbleView(
                message: Message(
                    content: component.text ?? component.title ?? "",
                    isUser: component.style == "user"
                )
            )
            .animatedAppearance(delay: Double(index) * 0.1)
            
        default:
            // Unknown component type — render as a placeholder
            UnknownComponentView(type: component.type)
                .animatedAppearance(delay: Double(index) * 0.1)
        }
    }
}

// MARK: - Unknown Component Fallback

/// Placeholder view for unrecognized component types.
struct UnknownComponentView: View {
    let type: String
    
    var body: some View {
        HStack {
            Image(systemName: "questionmark.diamond")
                .foregroundColor(JARVISColors.warning)
            Text("Unknown: \(type)")
                .font(JARVISFonts.caption())
                .foregroundColor(JARVISColors.textSecondary)
        }
        .padding()
        .glassMorphism()
    }
}

