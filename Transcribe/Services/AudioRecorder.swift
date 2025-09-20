//
//  AudioRecorder.swift
//  Transcribe
//
//  Created by Micke Kring on 2025-09-19.
//

import SwiftUI
import Combine
import AVFoundation

@MainActor
class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    @Published var audioLevels: [Float] = []
    @Published var currentAudioLevel: Float = 0
    @Published var hasRecordingPermission = false
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession?
    private var recordingTimer: Timer?
    private var levelTimer: Timer?
    private var currentRecordingURL: URL?
    
    override init() {
        super.init()
        Task {
            await setupSession()
        }
    }
    
    @MainActor
    private func setupSession() async {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
            
            await MainActor.run {
                recordingSession?.requestRecordPermission { [weak self] allowed in
                    Task { @MainActor in
                        self?.hasRecordingPermission = allowed
                        if !allowed {
                            print("Recording permission denied")
                        }
                    }
                }
            }
        } catch {
            print("Failed to setup recording session: \(error)")
        }
    }
    
    func startRecording() async throws {
        guard hasRecordingPermission else {
            throw RecordingError.permissionDenied
        }
        
        let audioFilename = getDocumentsDirectory()
            .appendingPathComponent("recording_\(Date().timeIntervalSince1970).m4a")
        
        currentRecordingURL = audioFilename
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            AVEncoderBitRateKey: 32000
        ]
        
        audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
        
        isRecording = true
        recordingTime = 0
        audioLevels = []
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            Task { @MainActor in
                self.recordingTime += 0.1
            }
        }
        
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in
                self.audioRecorder?.updateMeters()
                let level = self.audioRecorder?.averagePower(forChannel: 0) ?? -160
                let normalizedLevel = self.normalizeLevel(level)
                self.currentAudioLevel = normalizedLevel
                self.audioLevels.append(normalizedLevel)
                if self.audioLevels.count > 100 {
                    self.audioLevels.removeFirst()
                }
            }
        }
    }
    
    func stopRecording() -> URL? {
        recordingTimer?.invalidate()
        levelTimer?.invalidate()
        recordingTimer = nil
        levelTimer = nil
        
        audioRecorder?.stop()
        isRecording = false
        currentAudioLevel = 0
        
        return currentRecordingURL
    }
    
    func pauseRecording() {
        if isRecording {
            audioRecorder?.pause()
            recordingTimer?.invalidate()
            levelTimer?.invalidate()
        }
    }
    
    func resumeRecording() {
        if isRecording {
            audioRecorder?.record()
            
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                Task { @MainActor in
                    self.recordingTime += 0.1
                }
            }
            
            levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                Task { @MainActor in
                    self.audioRecorder?.updateMeters()
                    let level = self.audioRecorder?.averagePower(forChannel: 0) ?? -160
                    let normalizedLevel = self.normalizeLevel(level)
                    self.currentAudioLevel = normalizedLevel
                    self.audioLevels.append(normalizedLevel)
                    if self.audioLevels.count > 100 {
                        self.audioLevels.removeFirst()
                    }
                }
            }
        }
    }
    
    private func normalizeLevel(_ level: Float) -> Float {
        let minDb: Float = -60
        let maxDb: Float = 0
        return max(0, min(1, (level - minDb) / (maxDb - minDb)))
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func deleteRecording(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
}

enum RecordingError: LocalizedError {
    case permissionDenied
    case recordingFailed
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Mikrofontillstånd krävs för inspelning"
        case .recordingFailed:
            return "Inspelningen misslyckades"
        }
    }
}