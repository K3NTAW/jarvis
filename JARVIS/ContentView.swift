//
//  ContentView.swift
//  JARVIS
//
//  Root view for the JARVIS app.
//  iPhone: TabView with Chat, Canvas, and Settings.
//  tvOS: NavigationSplitView with sidebar.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var service = OpenClawService()
    @State private var selectedTab: AppTab = .chat
    
    var body: some View {
        #if os(tvOS)
        TVContentView(service: service)
        #else
        iOSContentView(service: service, selectedTab: $selectedTab)
        #endif
    }
}

// MARK: - App Tab

enum AppTab: String, CaseIterable {
    case chat = "Chat"
    case canvas = "Canvas"
    case settings = "Settings"
    
    var icon: String {
        switch self {
        case .chat: return "message.fill"
        case .canvas: return "sparkles.rectangle.stack"
        case .settings: return "gear"
        }
    }
}

// MARK: - iOS Content View

struct iOSContentView: View {
    @ObservedObject var service: OpenClawService
    @Binding var selectedTab: AppTab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ChatView(service: service)
                .tabItem {
                    Label(AppTab.chat.rawValue, systemImage: AppTab.chat.icon)
                }
                .tag(AppTab.chat)
            
            CanvasContainer(service: service)
                .tabItem {
                    Label(AppTab.canvas.rawValue, systemImage: AppTab.canvas.icon)
                }
                .tag(AppTab.canvas)
            
            SettingsView(service: service)
                .tabItem {
                    Label(AppTab.settings.rawValue, systemImage: AppTab.settings.icon)
                }
                .tag(AppTab.settings)
        }
        .tint(JARVISColors.primaryAccent)
        .preferredColorScheme(.dark)
    }
}

// MARK: - tvOS Content View

#if os(tvOS)
struct TVContentView: View {
    @ObservedObject var service: OpenClawService
    @State private var selectedSection: TVSection = .canvas
    
    enum TVSection: String, CaseIterable, Identifiable {
        case canvas = "JARVIS Interface"
        case chat = "Conversation"
        case media = "Media Library"
        case settings = "Settings"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .canvas: return "sparkles.rectangle.stack"
            case .chat: return "message.fill"
            case .media: return "play.rectangle.fill"
            case .settings: return "gear"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            List(TVSection.allCases, selection: $selectedSection) { section in
                Label(section.rawValue, systemImage: section.icon)
                    .tag(section)
            }
            .navigationTitle("J.A.R.V.I.S.")
        } detail: {
            switch selectedSection {
            case .canvas:
                CanvasContainer(service: service)
            case .chat:
                TVChatView(service: service)
            case .media:
                TVMediaBrowser(service: service)
            case .settings:
                SettingsView(service: service)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - TV Chat View

struct TVChatView: View {
    @ObservedObject var service: OpenClawService
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Messages
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(service.messages) { message in
                        VStack(spacing: 8) {
                            if !message.content.isEmpty {
                                ChatBubbleView(message: message)
                            }
                            if let blueprint = message.blueprint {
                                DynamicCanvasView(blueprint: blueprint)
                            }
                        }
                    }
                    
                    if service.isLoading {
                        TypingIndicator()
                    }
                }
                .padding(.horizontal, 40)
            }
            
            // Input
            HStack(spacing: 16) {
                TextField("Ask JARVIS...", text: $messageText)
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button("Send") {
                    sendMessage()
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messageText = ""
        Task {
            await service.sendMessage(text)
        }
    }
}

// MARK: - TV Media Browser

struct TVMediaBrowser: View {
    @ObservedObject var service: OpenClawService
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Media Library")
                .font(JARVISFonts.headline(32))
                .foregroundColor(JARVISColors.textPrimary)
            
            Text("Ask JARVIS to browse your media collection")
                .font(JARVISFonts.body(18))
                .foregroundColor(JARVISColors.textSecondary)
            
            Spacer()
            
            Image(systemName: "play.rectangle.on.rectangle")
                .font(.system(size: 60))
                .foregroundColor(JARVISColors.primaryAccent.opacity(0.3))
                .symbolEffect(.pulse, options: .repeating)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(JARVISColors.background)
    }
}
#endif

// MARK: - Preview

#Preview {
    ContentView()
}
