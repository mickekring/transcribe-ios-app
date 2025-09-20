//
//  TranscribeApp.swift
//  Transcribe
//
//  Created by Micke Kring on 2025-09-19.
//

import SwiftUI
import AVFoundation

@main
struct TranscribeApp: App {
    init() {
        print("DEBUG: TranscribeApp init started")
        setupApp()
        print("DEBUG: TranscribeApp init completed")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .onAppear {
                    print("DEBUG: Main view appeared")
                }
        }
    }
    
    private func setupApp() {
        print("DEBUG: Setting up app...")
        
        // Request microphone permission
        Task {
            await requestMicrophonePermission()
        }
        
        cleanupTemporaryFiles()
    }
    
    @MainActor
    private func requestMicrophonePermission() async {
        print("DEBUG: Requesting microphone permission")
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            print("DEBUG: Microphone permission granted: \(granted)")
        }
    }
    
    private func cleanupTemporaryFiles() {
        print("DEBUG: Cleaning up temporary files")
        let tempDir = FileManager.default.temporaryDirectory
        do {
            let files = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)
            var cleanedCount = 0
            for file in files {
                if file.pathExtension == "m4a" || file.lastPathComponent.starts(with: "chunk_") || file.lastPathComponent.starts(with: "recording_") {
                    try? FileManager.default.removeItem(at: file)
                    cleanedCount += 1
                }
            }
            print("DEBUG: Cleaned \(cleanedCount) temporary files")
        } catch {
            print("DEBUG: Failed to cleanup temp files: \(error)")
        }
    }
}
