//
//  StatusGridView.swift
//  JARVIS
//
//  Grid of status indicators (online/offline) for services/devices.
//  Each item shows a colored dot, label, and status text.
//

import SwiftUI

/// A grid displaying status indicators for multiple services.
struct StatusGridView: View {
    let data: BlueprintComponent
    
    private var columnCount: Int {
        data.columns ?? 2
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: columnCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = data.title {
                Text(title)
                    .font(JARVISFonts.caption(14))
                    .foregroundColor(JARVISColors.textSecondary)
                    .padding(.horizontal, 4)
            }
            
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(data.items ?? []) { item in
                    StatusItemView(item: item)
                }
            }
        }
        .padding(16)
        .glassMorphism()
    }
}

// MARK: - Status Item View

/// A single status indicator within the grid.
struct StatusItemView: View {
    let item: StatusItem
    
    private var statusColor: Color {
        if let color = JARVISColors.fromHex(item.color) {
            return color
        }
        switch item.status.lowercased() {
        case "online", "active", "running", "ok":
            return JARVISColors.success
        case "offline", "inactive", "stopped", "error":
            return JARVISColors.error
        case "warning", "degraded":
            return JARVISColors.warning
        default:
            return JARVISColors.textTertiary
        }
    }
    
    private var isOnline: Bool {
        ["online", "active", "running", "ok"].contains(item.status.lowercased())
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // Status dot
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .shadow(color: statusColor.opacity(0.8), radius: isOnline ? 4 : 0)
                .overlay(
                    Circle()
                        .stroke(statusColor.opacity(0.3), lineWidth: isOnline ? 2 : 0)
                        .scaleEffect(isOnline ? 1.8 : 1.0)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.label)
                    .font(JARVISFonts.body(14))
                    .foregroundColor(JARVISColors.textPrimary)
                
                Text(item.status.capitalized)
                    .font(JARVISFonts.caption(11))
                    .foregroundColor(statusColor)
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(JARVISColors.cardBackground.opacity(0.5))
        )
    }
}

// MARK: - Status Row View

/// Horizontal row of status items (alternative layout to grid).
struct StatusRowView: View {
    let data: BlueprintComponent
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(data.items ?? []) { item in
                    StatusItemView(item: item)
                        .frame(minWidth: 140)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .glassMorphism()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        JARVISColors.background.ignoresSafeArea()
        
        StatusGridView(data: BlueprintComponent(
            id: "services",
            type: "status_grid",
            columns: 2,
            items: [
                StatusItem(label: "Jellyfin", status: "online", color: "#00FF00"),
                StatusItem(label: "Radarr", status: "online", color: "#00FF00"),
                StatusItem(label: "Sonarr", status: "online", color: "#00FF00"),
                StatusItem(label: "qBittorrent", status: "offline", color: "#FF0000")
            ]
        ))
        .padding()
    }
}

