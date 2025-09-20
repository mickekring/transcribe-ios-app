//
//  TranscriptionResult.swift
//  Transcribe
//
//  Created by Micke Kring on 2025-09-19.
//

import Foundation

struct TranscriptionResult: Identifiable, Codable {
    let id = UUID()
    let text: String
    let language: String
    let segments: [TranscriptionSegment]
    let timestamp: Date
    let duration: TimeInterval
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "sv_SE")
        return formatter.string(from: timestamp)
    }
    
    var wordCount: Int {
        text.split(separator: " ").count
    }
}

struct TranscriptionSegment: Identifiable, Codable {
    let id: Int
    let text: String
    let start: Double
    let end: Double
    
    var timestamp: String {
        let startTime = formatTime(start)
        let endTime = formatTime(end)
        return "[\(startTime) - \(endTime)]"
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}