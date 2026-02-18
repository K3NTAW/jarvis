//
//  BlueprintComponents.swift
//  JARVIS
//
//  Component definitions for the Blueprint rendering system.
//  Each component represents a UI element that JARVIS can send.
//

import Foundation

// MARK: - BlueprintComponent

/// A single UI component within a blueprint.
/// Uses flexible JSON decoding to support various component types.
struct BlueprintComponent: Codable, Equatable, Identifiable {
    var id: String { _id ?? UUID().uuidString }
    
    private let _id: String?
    let type: String
    
    // Common properties
    let title: String?
    let subtitle: String?
    let value: String?
    let icon: String?
    let iconColor: String?
    let style: String?
    let action: String?
    
    // Status grid / status row
    let columns: Int?
    let items: [StatusItem]?
    
    // Media thumbnail
    let thumbnailUrl: String?
    let progress: Double?
    
    // Weather display
    let temperature: String?
    let condition: String?
    let conditionIcon: String?
    let location: String?
    let highLow: String?
    
    // Chart bar
    let data: [ChartDataPoint]?
    let maxValue: Double?
    
    // Progress ring
    let progressValue: Double?
    let label: String?
    let color: String?
    
    // Text block
    let text: String?
    let textStyle: String?
    let alignment: String?
    
    // Button
    let buttonStyle: String?
    let destructive: Bool?
    
    // Nested components (for containers)
    let components: [BlueprintComponent]?
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case type, title, subtitle, value, icon, iconColor, style, action
        case columns, items
        case thumbnailUrl, progress
        case temperature, condition, conditionIcon, location, highLow
        case data, maxValue
        case progressValue, label, color
        case text, textStyle, alignment
        case buttonStyle, destructive
        case components
    }
    
    init(
        id: String? = nil,
        type: String,
        title: String? = nil,
        subtitle: String? = nil,
        value: String? = nil,
        icon: String? = nil,
        iconColor: String? = nil,
        style: String? = nil,
        action: String? = nil,
        columns: Int? = nil,
        items: [StatusItem]? = nil,
        thumbnailUrl: String? = nil,
        progress: Double? = nil,
        temperature: String? = nil,
        condition: String? = nil,
        conditionIcon: String? = nil,
        location: String? = nil,
        highLow: String? = nil,
        data: [ChartDataPoint]? = nil,
        maxValue: Double? = nil,
        progressValue: Double? = nil,
        label: String? = nil,
        color: String? = nil,
        text: String? = nil,
        textStyle: String? = nil,
        alignment: String? = nil,
        buttonStyle: String? = nil,
        destructive: Bool? = nil,
        components: [BlueprintComponent]? = nil
    ) {
        self._id = id
        self.type = type
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.icon = icon
        self.iconColor = iconColor
        self.style = style
        self.action = action
        self.columns = columns
        self.items = items
        self.thumbnailUrl = thumbnailUrl
        self.progress = progress
        self.temperature = temperature
        self.condition = condition
        self.conditionIcon = conditionIcon
        self.location = location
        self.highLow = highLow
        self.data = data
        self.maxValue = maxValue
        self.progressValue = progressValue
        self.label = label
        self.color = color
        self.text = text
        self.textStyle = textStyle
        self.alignment = alignment
        self.buttonStyle = buttonStyle
        self.destructive = destructive
        self.components = components
    }
    
    static func == (lhs: BlueprintComponent, rhs: BlueprintComponent) -> Bool {
        lhs.id == rhs.id && lhs.type == rhs.type
    }
}

// MARK: - StatusItem

/// A single status indicator within a status grid.
struct StatusItem: Codable, Equatable, Identifiable {
    var id: String { label }
    let label: String
    let status: String
    let color: String?
    let icon: String?
    
    init(label: String, status: String, color: String? = nil, icon: String? = nil) {
        self.label = label
        self.status = status
        self.color = color
        self.icon = icon
    }
}

// MARK: - ChartDataPoint

/// A data point for bar chart components.
struct ChartDataPoint: Codable, Equatable, Identifiable {
    var id: String { label }
    let label: String
    let value: Double
    let color: String?
    
    init(label: String, value: Double, color: String? = nil) {
        self.label = label
        self.value = value
        self.color = color
    }
}

