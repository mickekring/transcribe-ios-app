//
//  AudioPreprocessor.swift
//  Transcribe
//
//  Created by Micke Kring on 2025-09-19.
//

import AVFoundation

class AudioPreprocessor {
    static let shared = AudioPreprocessor()
    
    private let maxDuration: Double = 600
    private let chunkDuration: Double = 540
    private let overlapDuration: Double = 30
    
    func preprocessAudio(url: URL) async throws -> [URL] {
        let asset = AVAsset(url: url)
        let duration = try await asset.load(.duration)
        let durationInSeconds = CMTimeGetSeconds(duration)
        
        if durationInSeconds <= maxDuration {
            return [url]
        }
        
        var chunks: [URL] = []
        var currentStart: Double = 0
        var chunkIndex = 0
        
        while currentStart < durationInSeconds {
            let chunkEnd = min(currentStart + chunkDuration, durationInSeconds)
            let chunkURL = try await extractChunk(
                from: asset,
                start: currentStart,
                end: chunkEnd,
                index: chunkIndex
            )
            chunks.append(chunkURL)
            
            currentStart = chunkEnd - overlapDuration
            chunkIndex += 1
            
            if chunkEnd >= durationInSeconds {
                break
            }
        }
        
        return chunks
    }
    
    private func extractChunk(from asset: AVAsset, start: Double, end: Double, index: Int) async throws -> URL {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("chunk_\(index).m4a")
        
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetAppleM4A
        ) else {
            throw AudioError.exportFailed
        }
        
        let startTime = CMTime(seconds: start, preferredTimescale: 1000)
        let endTime = CMTime(seconds: end, preferredTimescale: 1000)
        exportSession.timeRange = CMTimeRange(start: startTime, end: endTime)
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        
        await exportSession.export()
        
        guard exportSession.status == .completed else {
            throw AudioError.exportFailed
        }
        
        return outputURL
    }
    
    func cleanupChunks(_ urls: [URL]) {
        for url in urls {
            try? FileManager.default.removeItem(at: url)
        }
    }
}

enum AudioError: LocalizedError {
    case exportFailed
    case invalidAudioFile
    
    var errorDescription: String? {
        switch self {
        case .exportFailed:
            return "Kunde inte bearbeta ljudfilen"
        case .invalidAudioFile:
            return "Ogiltig ljudfil"
        }
    }
}