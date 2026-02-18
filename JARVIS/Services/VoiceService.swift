//
//  VoiceService.swift
//  JARVIS
//
//  Voice input service using Apple's Speech framework (SFSpeechRecognizer).
//  Provides speech-to-text for hands-free JARVIS interaction.
//

import Foundation
import Speech
import AVFoundation

/// Manages voice recognition for hands-free JARVIS interaction.
@MainActor
class VoiceService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isListening = false
    @Published var transcribedText = ""
    @Published var isAuthorized = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // MARK: - Initialization
    
    init() {
        // Don't auto-request authorization on init.
        // Authorization is requested lazily when user first taps the mic button.
        updateAuthorizationStatus()
    }
    
    // MARK: - Authorization
    
    /// Updates the current authorization status without prompting the user.
    private func updateAuthorizationStatus() {
        let status = SFSpeechRecognizer.authorizationStatus()
        isAuthorized = (status == .authorized)
    }
    
    /// Request speech recognition authorization (called on first mic tap).
    func requestAuthorization() {
        let currentStatus = SFSpeechRecognizer.authorizationStatus()
        
        if currentStatus == .authorized {
            isAuthorized = true
            return
        }
        
        if currentStatus == .notDetermined {
            SFSpeechRecognizer.requestAuthorization { [weak self] status in
                Task { @MainActor in
                    switch status {
                    case .authorized:
                        self?.isAuthorized = true
                    case .denied, .restricted, .notDetermined:
                        self?.isAuthorized = false
                        self?.errorMessage = "Speech recognition not authorized"
                    @unknown default:
                        self?.isAuthorized = false
                    }
                }
            }
        } else {
            isAuthorized = false
            errorMessage = "Speech recognition not authorized. Enable it in Settings."
        }
    }
    
    // MARK: - Listening Control
    
    /// Start listening for voice input.
    func startListening() {
        // Request authorization on first use
        if !isAuthorized {
            requestAuthorization()
        }
        
        guard isAuthorized else {
            errorMessage = "Speech recognition not authorized. Please enable in Settings."
            return
        }
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition unavailable"
            return
        }
        
        // Cancel any existing task
        stopListening()
        
        do {
            try startAudioSession()
            try startRecognition(with: speechRecognizer)
            isListening = true
            transcribedText = ""
            errorMessage = nil
        } catch {
            errorMessage = "Failed to start voice input: \(error.localizedDescription)"
            isListening = false
        }
    }
    
    /// Stop listening for voice input.
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isListening = false
    }
    
    /// Toggle listening state.
    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            startListening()
        }
    }
    
    // MARK: - Private Methods
    
    /// Configure the audio session for recording.
    private func startAudioSession() throws {
        #if os(iOS)
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        #endif
    }
    
    /// Start the speech recognition process.
    private func startRecognition(with recognizer: SFSpeechRecognizer) throws {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            throw VoiceServiceError.requestCreationFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Use on-device recognition if available (faster, more private)
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = recognizer.supportsOnDeviceRecognition
        }
        
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                if let result = result {
                    self?.transcribedText = result.bestTranscription.formattedString
                }
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    self?.stopListening()
                }
                
                if result?.isFinal == true {
                    self?.stopListening()
                }
            }
        }
        
        // Install tap on audio engine input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
}

// MARK: - Voice Service Errors

enum VoiceServiceError: LocalizedError {
    case requestCreationFailed
    case audioSessionFailed
    case notAuthorized
    
    var errorDescription: String? {
        switch self {
        case .requestCreationFailed:
            return "Failed to create speech recognition request"
        case .audioSessionFailed:
            return "Failed to configure audio session"
        case .notAuthorized:
            return "Speech recognition not authorized"
        }
    }
}

