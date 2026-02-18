//
//  Blueprint.swift
//  JARVIS
//
//  Blueprint model for dynamic UI rendering.
//  The AI sends these JSON blueprints which the app renders into SwiftUI views.
//

import Foundation

// MARK: - Blueprint

/// Top-level blueprint container sent by the AI.
/// Can contain a layout type, title, styling, animation, and child components.
struct Blueprint: Codable, Equatable, Identifiable {
    var id: String { _id ?? UUID().uuidString }
    
    private let _id: String?
    let type: BlueprintType
    let title: String?
    let style: String?
    let animation: String?
    let components: [BlueprintComponent]?
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case type, title, style, animation, components
    }
    
    init(
        id: String? = nil,
        type: BlueprintType,
        title: String? = nil,
        style: String? = nil,
        animation: String? = nil,
        components: [BlueprintComponent]? = nil
    ) {
        self._id = id
        self.type = type
        self.title = title
        self.style = style
        self.animation = animation
        self.components = components
    }
    
    static func == (lhs: Blueprint, rhs: Blueprint) -> Bool {
        lhs.id == rhs.id && lhs.type == rhs.type && lhs.title == rhs.title
    }
}

// MARK: - BlueprintType

/// The layout type of a blueprint container.
enum BlueprintType: String, Codable {
    case dashboard
    case card
    case list
    case mediaBrowser = "media_browser"
    case settings
    case custom
}

// MARK: - BlueprintAnimation

/// Animation types supported for blueprint transitions.
enum BlueprintAnimation: String, Codable {
    case fade
    case slideUp = "slideUp"
    case scale
    case fadeSlideUp = "fadeSlideUp"
    case none
    
    init(from string: String?) {
        guard let string = string else {
            self = .none
            return
        }
        self = BlueprintAnimation(rawValue: string) ?? .none
    }
}

