//
//  DynamicCanvasView.swift
//  JARVIS
//
//  The core "dumb renderer" — takes a Blueprint and renders it as SwiftUI.
//  This is the magic: AI designs the UI, this view renders it.
//

import SwiftUI

/// Renders a Blueprint into a dynamic SwiftUI interface.
struct DynamicCanvasView: View {
    let blueprint: Blueprint
    
    @State private var isVisible = false
    
    private var animation: BlueprintAnimation {
        BlueprintAnimation(from: blueprint.animation)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Blueprint title header
            if let title = blueprint.title {
                HStack {
                    Rectangle()
                        .fill(JARVISColors.primaryAccent)
                        .frame(width: 3, height: 20)
                        .cornerRadius(1.5)
                    
                    Text(title)
                        .font(JARVISFonts.title(18))
                        .foregroundColor(JARVISColors.textPrimary)
                    
                    Spacer()
                    
                    // Blueprint type badge
                    Text(blueprint.type.rawValue.uppercased())
                        .font(JARVISFonts.mono(9))
                        .foregroundColor(JARVISColors.primaryAccent.opacity(0.6))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .stroke(JARVISColors.primaryAccent.opacity(0.3), lineWidth: 0.5)
                        )
                }
                .padding(.horizontal, 4)
            }
            
            // Render components based on blueprint type
            blueprintContent
        }
        .padding(12)
        .glassMorphism(cornerRadius: 20)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .scaleEffect(isVisible ? 1 : 0.95)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isVisible = true
            }
        }
    }
    
    // MARK: - Blueprint Content
    
    @ViewBuilder
    private var blueprintContent: some View {
        if let components = blueprint.components {
            switch blueprint.type {
            case .dashboard:
                dashboardLayout(components: components)
            case .card:
                cardLayout(components: components)
            case .list:
                listLayout(components: components)
            case .mediaBrowser:
                mediaBrowserLayout(components: components)
            case .settings:
                settingsLayout(components: components)
            case .custom:
                customLayout(components: components)
            }
        }
    }
    
    // MARK: - Layout Strategies
    
    /// Dashboard: responsive grid with mixed component sizes.
    @ViewBuilder
    private func dashboardLayout(components: [BlueprintComponent]) -> some View {
        let statCards = components.filter { $0.type == "stat_card" }
        let otherComponents = components.filter { $0.type != "stat_card" }
        
        // Stat cards in a 2-column grid
        if !statCards.isEmpty {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(Array(statCards.enumerated()), id: \.element.id) { index, component in
                    ComponentRegistry.view(for: component, index: index)
                }
            }
        }
        
        // Other components stacked vertically
        ForEach(Array(otherComponents.enumerated()), id: \.element.id) { index, component in
            ComponentRegistry.view(for: component, index: statCards.count + index)
        }
    }
    
    /// Card: single column, stacked.
    @ViewBuilder
    private func cardLayout(components: [BlueprintComponent]) -> some View {
        ForEach(Array(components.enumerated()), id: \.element.id) { index, component in
            ComponentRegistry.view(for: component, index: index)
        }
    }
    
    /// List: vertical list of items.
    @ViewBuilder
    private func listLayout(components: [BlueprintComponent]) -> some View {
        VStack(spacing: 8) {
            ForEach(Array(components.enumerated()), id: \.element.id) { index, component in
                ComponentRegistry.view(for: component, index: index)
            }
        }
    }
    
    /// Media browser: horizontal scrolling thumbnails.
    @ViewBuilder
    private func mediaBrowserLayout(components: [BlueprintComponent]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(Array(components.enumerated()), id: \.element.id) { index, component in
                    ComponentRegistry.view(for: component, index: index)
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    /// Settings: list-like layout with dividers.
    @ViewBuilder
    private func settingsLayout(components: [BlueprintComponent]) -> some View {
        VStack(spacing: 4) {
            ForEach(Array(components.enumerated()), id: \.element.id) { index, component in
                ComponentRegistry.view(for: component, index: index)
                
                if index < components.count - 1 {
                    DividerView()
                }
            }
        }
    }
    
    /// Custom: free-form, vertical stack.
    @ViewBuilder
    private func customLayout(components: [BlueprintComponent]) -> some View {
        ForEach(Array(components.enumerated()), id: \.element.id) { index, component in
            ComponentRegistry.view(for: component, index: index)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        DynamicCanvasView(blueprint: Blueprint(
            id: "demo",
            type: .dashboard,
            title: "Server Status",
            style: "jarvis_dark",
            animation: "fadeSlideUp",
            components: [
                BlueprintComponent(
                    id: "header_1",
                    type: "header",
                    title: "System Overview",
                    subtitle: "All systems operational"
                ),
                BlueprintComponent(
                    id: "storage_stat",
                    type: "stat_card",
                    title: "Storage",
                    subtitle: "Free of 7.3TB",
                    value: "6.7TB",
                    icon: "internaldrive",
                    iconColor: "#00FFFF"
                ),
                BlueprintComponent(
                    id: "cpu_stat",
                    type: "stat_card",
                    title: "CPU Usage",
                    subtitle: "4 cores active",
                    value: "23%",
                    icon: "cpu",
                    iconColor: "#9D00FF"
                ),
                BlueprintComponent(
                    id: "services",
                    type: "status_grid",
                    columns: 2,
                    items: [
                        StatusItem(label: "Jellyfin", status: "online", color: "#00FF00"),
                        StatusItem(label: "Radarr", status: "online", color: "#00FF00"),
                        StatusItem(label: "Sonarr", status: "online", color: "#00FF00"),
                        StatusItem(label: "qBittorrent", status: "offline", color: "#FF0000")
                    ]
                ),
                BlueprintComponent(
                    id: "weather",
                    type: "weather_display",
                    temperature: "7°C",
                    condition: "Cloudy",
                    conditionIcon: "cloud.fill",
                    location: "Zurich",
                    highLow: "10°C / 4°C"
                )
            ]
        ))
        .padding()
    }
    .background(JARVISColors.background)
}

