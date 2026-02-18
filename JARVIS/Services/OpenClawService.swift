//
//  OpenClawService.swift
//  JARVIS
//
//  Manages communication with the OpenClaw AI assistant API.
//  Handles sending messages, receiving responses, and parsing blueprints.
//

import Foundation
import SwiftUI

/// Service responsible for communicating with the OpenClaw AI backend.
@MainActor
class OpenClawService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var messages: [Message] = []
    @Published var currentBlueprint: Blueprint?
    @Published var isLoading = false
    @Published var isConnected = false
    @Published var errorMessage: String?
    
    // MARK: - Configuration
    
    /// The base URL for the OpenClaw API.
    /// Configure this to point to your OpenClaw instance (e.g., http://192.168.1.100:3000).
    private var baseURL: String {
        UserDefaults.standard.string(forKey: "openClawBaseURL") ?? "http://localhost:3000"
    }
    
    /// The API key for authentication.
    private var apiKey: String {
        UserDefaults.standard.string(forKey: "openClawAPIKey") ?? ""
    }
    
    /// The model to use (e.g., "gpt-4o", "claude-3-opus", or whatever your gateway supports).
    private var model: String {
        UserDefaults.standard.string(forKey: "openClawModel") ?? "gpt-4o"
    }
    
    /// The JARVIS system prompt that instructs the AI to respond with blueprints.
    private var systemPrompt: String {
        """
        You are JARVIS (Just A Rather Very Intelligent System), a highly intelligent AI assistant \
        inspired by Tony Stark's AI. You are helpful, witty, and slightly formal — always addressing \
        the user as "Sir" or "Ma'am."
        
        You have a special capability: you can create visual UI components by including a JSON \
        blueprint in your response. When the user asks about something that would benefit from \
        a visual display (server status, weather, media, statistics, etc.), include a JSON blueprint \
        block in your response.
        
        Blueprint format — include this JSON anywhere in your response when appropriate:
        {
          "type": "dashboard",
          "title": "Title Here",
          "style": "jarvis_dark",
          "animation": "fadeSlideUp",
          "components": [
            {
              "type": "stat_card",
              "id": "unique_id",
              "icon": "sf_symbol_name",
              "iconColor": "#00FFFF",
              "title": "Label",
              "value": "123",
              "subtitle": "Description"
            },
            {
              "type": "status_grid",
              "id": "unique_id",
              "columns": 2,
              "items": [
                {"label": "Service", "status": "online", "color": "#00FF00"}
              ]
            },
            {
              "type": "weather_display",
              "id": "unique_id",
              "temperature": "7°C",
              "condition": "Cloudy",
              "conditionIcon": "cloud.fill",
              "location": "City",
              "highLow": "10°C / 4°C"
            },
            {
              "type": "progress_ring",
              "id": "unique_id",
              "title": "Label",
              "value": "67%",
              "progressValue": 0.67,
              "color": "#00FFFF"
            },
            {
              "type": "header",
              "id": "unique_id",
              "title": "Section Title",
              "subtitle": "Optional subtitle"
            },
            {
              "type": "text_block",
              "id": "unique_id",
              "text": "Some text content",
              "textStyle": "body"
            }
          ]
        }
        
        Available component types: stat_card, status_grid, status_row, media_thumbnail, \
        weather_display, progress_ring, chart_bar, text_block, list_item, header, divider, button.
        
        Available SF Symbol icons: server, cpu, memorychip, internaldrive, network, wifi, \
        cloud.fill, sun.max.fill, thermometer, play.circle.fill, film, tv, music.note, \
        house.fill, lightbulb.fill, lock.fill, bell.fill, arrow.clockwise, gear, and more.
        
        Blueprint types: dashboard (grid layout), card (single column), list (vertical list), \
        media_browser (horizontal scroll), settings (list with dividers), custom (freeform).
        
        Rules:
        - Only include a blueprint when it adds value (don't force it for simple text answers)
        - Always include some text explanation alongside the blueprint
        - Use realistic SF Symbol names for icons
        - Use hex colors (#00FFFF for cyan, #9D00FF for purple, #00FF00 for green, #FF0000 for red)
        - Keep responses concise and helpful
        """
    }
    
    // MARK: - Initialization
    
    init() {
        // Add a welcome message from JARVIS
        let welcomeMessage = Message(
            content: "Good \(timeOfDayGreeting), Sir. All systems are operational. How may I assist you today?",
            isUser: false,
            blueprint: nil
        )
        messages.append(welcomeMessage)
    }
    
    // MARK: - Public Methods
    
    /// Send a message to JARVIS and receive a response.
    func sendMessage(_ text: String) async {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        let userMessage = Message(content: text, isUser: true)
        messages.append(userMessage)
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await callOpenClawAPI(message: text)
            let parsed = BlueprintParser.parse(from: response)
            
            let jarvisMessage = Message(
                content: parsed.text,
                isUser: false,
                blueprint: parsed.blueprint
            )
            
            messages.append(jarvisMessage)
            
            if let blueprint = parsed.blueprint {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    currentBlueprint = blueprint
                }
            }
        } catch {
            // On error, provide a fallback response
            let errorMsg = Message(
                content: "I'm having trouble connecting to my systems, Sir. Error: \(error.localizedDescription)",
                isUser: false
            )
            messages.append(errorMsg)
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Configure the API connection settings.
    func configure(baseURL: String, apiKey: String, model: String? = nil) {
        UserDefaults.standard.set(baseURL, forKey: "openClawBaseURL")
        UserDefaults.standard.set(apiKey, forKey: "openClawAPIKey")
        if let model = model {
            UserDefaults.standard.set(model, forKey: "openClawModel")
        }
    }
    
    /// Clear chat history.
    func clearHistory() {
        messages.removeAll()
        currentBlueprint = nil
        
        let welcomeMessage = Message(
            content: "Chat cleared, Sir. Ready for new instructions.",
            isUser: false
        )
        messages.append(welcomeMessage)
    }
    
    /// Inject a demo blueprint for testing/preview purposes.
    func injectDemoBlueprint() {
        let demoJSON = """
        {
            "type": "dashboard",
            "id": "demo_dashboard",
            "title": "Server Status",
            "style": "jarvis_dark",
            "animation": "fadeSlideUp",
            "components": [
                {
                    "type": "header",
                    "id": "header_1",
                    "title": "System Overview",
                    "subtitle": "All systems operational"
                },
                {
                    "type": "stat_card",
                    "id": "storage_stat",
                    "icon": "internaldrive",
                    "iconColor": "#00FFFF",
                    "title": "Storage",
                    "value": "6.7TB",
                    "subtitle": "Free of 7.3TB"
                },
                {
                    "type": "stat_card",
                    "id": "cpu_stat",
                    "icon": "cpu",
                    "iconColor": "#9D00FF",
                    "title": "CPU Usage",
                    "value": "23%",
                    "subtitle": "4 cores active"
                },
                {
                    "type": "stat_card",
                    "id": "memory_stat",
                    "icon": "memorychip",
                    "iconColor": "#00FF00",
                    "title": "Memory",
                    "value": "12.4GB",
                    "subtitle": "of 32GB used"
                },
                {
                    "type": "status_grid",
                    "id": "services_status",
                    "columns": 2,
                    "items": [
                        {"label": "Jellyfin", "status": "online", "color": "#00FF00"},
                        {"label": "Radarr", "status": "online", "color": "#00FF00"},
                        {"label": "Sonarr", "status": "online", "color": "#00FF00"},
                        {"label": "qBittorrent", "status": "offline", "color": "#FF0000"}
                    ]
                },
                {
                    "type": "weather_display",
                    "id": "zurich_weather",
                    "temperature": "7°C",
                    "condition": "Cloudy",
                    "conditionIcon": "cloud.fill",
                    "location": "Zurich",
                    "highLow": "10°C / 4°C"
                }
            ]
        }
        """
        
        if let blueprint = BlueprintParser.decodeBlueprint(from: demoJSON) {
            let message = Message(
                content: "Here's your server status overview, Sir.",
                isUser: false,
                blueprint: blueprint
            )
            messages.append(message)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                currentBlueprint = blueprint
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Makes the actual API call to OpenClaw.
    /// Supports OpenAI-compatible `/v1/chat/completions` format.
    private func callOpenClawAPI(message: String) async throws -> String {
        // Build conversation history for context
        let chatMessages = buildChatMessages(newMessage: message)
        
        guard let url = URL(string: "\(baseURL)/v1/chat/completions") else {
            throw OpenClawError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        
        if !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        
        let body: [String: Any] = [
            "model": model,
            "messages": chatMessages,
            "temperature": 0.7,
            "max_tokens": 4096
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenClawError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to extract error message from response body
            if let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorInfo = errorBody["error"] as? [String: Any],
               let errorMsg = errorInfo["message"] as? String {
                throw OpenClawError.serverErrorMessage(errorMsg)
            }
            throw OpenClawError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // Parse OpenAI-compatible response
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let messageObj = firstChoice["message"] as? [String: Any],
           let content = messageObj["content"] as? String {
            return content
        }
        
        // Fallback: try simple { "message": "..." } format
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let messageContent = json["message"] as? String {
            return messageContent
        }
        
        // Last resort: raw string
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw OpenClawError.decodingError
        }
        
        return responseString
    }
    
    /// Builds the messages array for the OpenAI-compatible API,
    /// including the JARVIS system prompt and conversation history.
    private func buildChatMessages(newMessage: String) -> [[String: String]] {
        var chatMessages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        // Add recent conversation history (last 20 messages for context)
        let recentMessages = messages.suffix(20)
        for msg in recentMessages {
            chatMessages.append([
                "role": msg.isUser ? "user" : "assistant",
                "content": msg.content
            ])
        }
        
        // Add the new user message
        chatMessages.append(["role": "user", "content": newMessage])
        
        return chatMessages
    }
    
    /// Returns appropriate time-of-day greeting.
    private var timeOfDayGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "morning"
        case 12..<17: return "afternoon"
        case 17..<22: return "evening"
        default: return "evening"
        }
    }
}

// MARK: - OpenClaw Errors

enum OpenClawError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case serverErrorMessage(String)
    case decodingError
    case notConnected
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL configuration. Check your base URL in Settings."
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error (HTTP \(code))"
        case .serverErrorMessage(let msg):
            return msg
        case .decodingError:
            return "Failed to decode response"
        case .notConnected:
            return "Not connected to OpenClaw. Check your URL and network."
        }
    }
}

