//
//  WhisperKitService.swift
//  Transcribe
//
//  Created by Micke Kring on 2025-09-19.
//

import Foundation
import SwiftUI
import Combine
import WhisperKit
import AVFoundation

@MainActor
class WhisperKitService: ObservableObject {
    @Published var isLoading = false
    @Published var currentModel: String?
    @Published var availableModels: [String] = []
    @Published var downloadProgress: Double = 0
    @Published var transcriptionProgress: Double = 0
    @Published var isTranscribing = false
    
    private var whisperKit: WhisperKit?
    
    let modelOptions = [
        ModelOption(id: "kb_whisper-base", name: "KB Whisper Base (Svenska)", size: "150 MB", language: "sv"),
        ModelOption(id: "kb_whisper-small", name: "KB Whisper Small (Svenska)", size: "500 MB", language: "sv"),
        ModelOption(id: "openai_whisper-base", name: "Whisper Base", size: "150 MB", language: nil),
        ModelOption(id: "openai_whisper-small", name: "Whisper Small", size: "500 MB", language: nil),
    ]
    
    func loadModel(_ modelId: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        if modelId.starts(with: "kb_whisper-") {
            let variant = modelId.replacingOccurrences(of: "kb_whisper-", with: "")
            
            let config = WhisperKitConfig(
                model: variant,
                modelRepo: "mickekringai/kb-whisper-coreml",
                verbose: true,
                logLevel: .debug
            )
            
            whisperKit = try await WhisperKit(config)
            currentModel = modelId
            
        } else {
            let variant = modelId.replacingOccurrences(of: "openai_whisper-", with: "")
            whisperKit = try await WhisperKit(model: variant)
            currentModel = modelId
        }
    }
    
    func transcribe(audioURL: URL, language: String? = nil) async throws -> TranscriptionResult {
        guard let whisperKit = whisperKit else {
            throw TranscriptionError.modelNotLoaded
        }
        
        isTranscribing = true
        transcriptionProgress = 0
        defer {
            isTranscribing = false
            transcriptionProgress = 0
        }
        
        let options = DecodingOptions(
            language: language,
            temperature: 0,
            temperatureFallbackCount: 3,
            sampleLength: 224,
            topK: 5,
            usePrefillPrompt: true,
            usePrefillCache: true,
            skipSpecialTokens: true
        )
        
        let results = try await whisperKit.transcribe(
            audioPath: audioURL.path,
            decodeOptions: options
        )
        
        return TranscriptionResult(
            text: results.map { $0.text }.joined(separator: " "),
            language: results.first?.language ?? "unknown",
            segments: results.enumerated().map { index, segment in
                TranscriptionSegment(
                    id: index,
                    text: segment.text,
                    start: 0,
                    end: 0
                )
            },
            timestamp: Date(),
            duration: getDuration(for: audioURL)
        )
    }
    
    private func getDuration(for url: URL) -> TimeInterval {
        let asset = AVURLAsset(url: url)
        let duration = asset.duration.seconds
        if !duration.isNaN {
            return duration
        }
        return 0
    }
}

struct ModelOption: Identifiable {
    let id: String
    let name: String
    let size: String
    let language: String?
}

enum TranscriptionError: LocalizedError {
    case modelNotLoaded
    case audioProcessingFailed
    case transcriptionFailed
    
    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "AI-modellen är inte laddad"
        case .audioProcessingFailed:
            return "Kunde inte bearbeta ljudfilen"
        case .transcriptionFailed:
            return "Transkriberingen misslyckades"
        }
    }
}