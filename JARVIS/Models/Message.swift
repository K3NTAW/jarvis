//
//  Message.swift
//  JARVIS
//
//  Chat message model for JARVIS conversations.
//

import Foundation

/// Represents a single message in the JARVIS chat conversation.
struct Message: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    let blueprint: Blueprint?
    
    init(
        id: UUID = UUID(),
        content: String,
        isUser: Bool,
        timestamp: Date = Date(),
        blueprint: Blueprint? = nil
    ) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.blueprint = blueprint
    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}

