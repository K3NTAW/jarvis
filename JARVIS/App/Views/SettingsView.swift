//
//  SettingsView.swift
//  JARVIS
//
//  Settings view for configuring the OpenClaw API connection,
//  app preferences, and viewing system information.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var service: OpenClawService
    
    @AppStorage("openClawBaseURL") private var baseURL = "http://localhost:3000"
    @AppStorage("openClawAPIKey") private var apiKey = ""
    @AppStorage("openClawModel") private var model = "gpt-4o"
    @State private var showAPIKey = false
    @State private var testConnectionResult: String?
    @State private var isTesting = false
    
    var body: some View {
        ZStack {
            JARVISColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    settingsHeader
                    
                    // API Configuration
                    apiSection
                    
                    // App Info
                    appInfoSection
                    
                    // Actions
                    actionsSection
                }
                .padding()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Header
    
    private var settingsHeader: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(JARVISColors.primaryAccent.opacity(0.2), lineWidth: 2)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .fill(JARVISColors.primaryAccent)
                    .frame(width: 20, height: 20)
                    .glowEffect(color: JARVISColors.primaryAccent, radius: 8)
            }
            
            Text("J.A.R.V.I.S.")
                .font(JARVISFonts.headline(24))
                .foregroundColor(JARVISColors.textPrimary)
            
            Text("Just A Rather Very Intelligent System")
                .font(JARVISFonts.caption(12))
                .foregroundColor(JARVISColors.textTertiary)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - API Section
    
    private var apiSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("API Configuration")
                .font(JARVISFonts.title(16))
                .foregroundColor(JARVISColors.textPrimary)
            
            VStack(spacing: 12) {
                // Base URL
                VStack(alignment: .leading, spacing: 6) {
                    Text("OpenClaw Base URL")
                        .font(JARVISFonts.caption(12))
                        .foregroundColor(JARVISColors.textSecondary)
                    
                    TextField("http://localhost:3000", text: $baseURL)
                        .font(JARVISFonts.mono(14))
                        .foregroundColor(JARVISColors.textPrimary)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(JARVISColors.inputBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(JARVISColors.divider.opacity(0.3), lineWidth: 0.5)
                        )
                        .tint(JARVISColors.primaryAccent)
                        #if os(iOS)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        #endif
                }
                
                // API Key
                VStack(alignment: .leading, spacing: 6) {
                    Text("API Key")
                        .font(JARVISFonts.caption(12))
                        .foregroundColor(JARVISColors.textSecondary)
                    
                    HStack {
                        if showAPIKey {
                            TextField("Enter API key", text: $apiKey)
                                .font(JARVISFonts.mono(14))
                        } else {
                            SecureField("Enter API key", text: $apiKey)
                                .font(JARVISFonts.mono(14))
                        }
                        
                        Button(action: { showAPIKey.toggle() }) {
                            Image(systemName: showAPIKey ? "eye.slash" : "eye")
                                .foregroundColor(JARVISColors.textTertiary)
                        }
                        .buttonStyle(.plain)
                    }
                    .foregroundColor(JARVISColors.textPrimary)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(JARVISColors.inputBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(JARVISColors.divider.opacity(0.3), lineWidth: 0.5)
                    )
                    .tint(JARVISColors.primaryAccent)
                    #if os(iOS)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    #endif
                }
                
                // Model
                VStack(alignment: .leading, spacing: 6) {
                    Text("Model")
                        .font(JARVISFonts.caption(12))
                        .foregroundColor(JARVISColors.textSecondary)
                    
                    TextField("gpt-4o", text: $model)
                        .font(JARVISFonts.mono(14))
                        .foregroundColor(JARVISColors.textPrimary)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(JARVISColors.inputBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(JARVISColors.divider.opacity(0.3), lineWidth: 0.5)
                        )
                        .tint(JARVISColors.primaryAccent)
                        #if os(iOS)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        #endif
                }
                
                // Save & Test buttons
                HStack(spacing: 12) {
                    Button(action: saveConfiguration) {
                        HStack {
                            Image(systemName: "checkmark.circle")
                            Text("Save")
                        }
                        .font(JARVISFonts.body(14))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(JARVISColors.primaryAccent)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: testConnection) {
                        HStack {
                            if isTesting {
                                ProgressView()
                                    .tint(JARVISColors.primaryAccent)
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                            }
                            Text("Test")
                        }
                        .font(JARVISFonts.body(14))
                        .foregroundColor(JARVISColors.primaryAccent)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .stroke(JARVISColors.primaryAccent.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(isTesting)
                }
                
                // Test result
                if let result = testConnectionResult {
                    Text(result)
                        .font(JARVISFonts.caption(12))
                        .foregroundColor(
                            result.contains("Success") ? JARVISColors.success : JARVISColors.error
                        )
                        .padding(.top, 4)
                }
            }
            .padding(16)
            .glassMorphism()
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("System Information")
                .font(JARVISFonts.title(16))
                .foregroundColor(JARVISColors.textPrimary)
            
            VStack(spacing: 0) {
                infoRow(label: "Version", value: "1.0.0")
                Divider().background(JARVISColors.divider.opacity(0.3))
                infoRow(label: "Platform", value: platformName)
                Divider().background(JARVISColors.divider.opacity(0.3))
                infoRow(label: "Components", value: "13 types")
                Divider().background(JARVISColors.divider.opacity(0.3))
                infoRow(label: "Messages", value: "\(service.messages.count)")
            }
            .glassMorphism()
        }
    }
    
    // MARK: - Actions Section
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actions")
                .font(JARVISFonts.title(16))
                .foregroundColor(JARVISColors.textPrimary)
            
            VStack(spacing: 12) {
                Button(action: { service.injectDemoBlueprint() }) {
                    actionRow(icon: "wand.and.stars", title: "Load Demo Dashboard", color: JARVISColors.primaryAccent)
                }
                .buttonStyle(.plain)
                
                Button(action: { service.clearHistory() }) {
                    actionRow(icon: "trash", title: "Clear Chat History", color: JARVISColors.warning)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(JARVISFonts.body(14))
                .foregroundColor(JARVISColors.textSecondary)
            Spacer()
            Text(value)
                .font(JARVISFonts.mono(14))
                .foregroundColor(JARVISColors.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func actionRow(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(Circle().fill(color.opacity(0.15)))
            
            Text(title)
                .font(JARVISFonts.body(15))
                .foregroundColor(JARVISColors.textPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(JARVISColors.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassMorphism(cornerRadius: 12)
    }
    
    private var platformName: String {
        #if os(tvOS)
        return "tvOS"
        #elseif os(iOS)
        return "iOS"
        #elseif os(macOS)
        return "macOS"
        #else
        return "Unknown"
        #endif
    }
    
    // MARK: - Actions
    
    private func saveConfiguration() {
        service.configure(baseURL: baseURL, apiKey: apiKey, model: model)
    }
    
    private func testConnection() {
        isTesting = true
        testConnectionResult = nil
        
        Task {
            do {
                // Try /v1/models endpoint (standard OpenAI-compatible check)
                guard let url = URL(string: "\(baseURL)/v1/models") else {
                    testConnectionResult = "❌ Invalid URL"
                    isTesting = false
                    return
                }
                
                var request = URLRequest(url: url)
                request.timeoutInterval = 10
                if !apiKey.isEmpty {
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                }
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = response as? HTTPURLResponse {
                    if (200...299).contains(httpResponse.statusCode) {
                        // Try to count available models
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let models = json["data"] as? [[String: Any]] {
                            let modelNames = models.compactMap { $0["id"] as? String }.prefix(5).joined(separator: ", ")
                            testConnectionResult = "✅ Connected! Models: \(modelNames)"
                        } else {
                            testConnectionResult = "✅ Connected to OpenClaw gateway"
                        }
                    } else if httpResponse.statusCode == 401 {
                        testConnectionResult = "⚠️ Connected but unauthorized — check your API key"
                    } else {
                        testConnectionResult = "⚠️ Server responded with HTTP \(httpResponse.statusCode)"
                    }
                }
            } catch let error as URLError {
                switch error.code {
                case .cannotConnectToHost:
                    testConnectionResult = "❌ Cannot connect — is the server running?"
                case .timedOut:
                    testConnectionResult = "❌ Connection timed out"
                case .notConnectedToInternet:
                    testConnectionResult = "❌ No internet connection"
                default:
                    testConnectionResult = "❌ \(error.localizedDescription)"
                }
            } catch {
                testConnectionResult = "❌ \(error.localizedDescription)"
            }
            
            isTesting = false
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView(service: OpenClawService())
}

