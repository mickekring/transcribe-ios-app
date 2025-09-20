//
//  RecordingView.swift
//  Transcribe
//
//  Created by Micke Kring on 2025-09-19.
//

import SwiftUI

struct RecordingView: View {
    @EnvironmentObject private var recorder: AudioRecorder
    @EnvironmentObject private var whisperService: WhisperKitService
    @State private var transcriptionResult: TranscriptionResult?
    @State private var isTranscribing = false
    @State private var showingResult = false
    @State private var pulseAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.07, green: 0.07, blue: 0.12),
                        Color(red: 0.02, green: 0.02, blue: 0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    ZStack {
                        WaveformVisualizer(levels: recorder.audioLevels, currentLevel: recorder.currentAudioLevel)
                            .frame(height: 200)
                            .padding(.horizontal)
                        
                        if recorder.isRecording {
                            Circle()
                                .fill(.red.opacity(0.1))
                                .frame(width: 300, height: 300)
                                .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                                .opacity(pulseAnimation ? 0 : 0.8)
                                .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulseAnimation)
                                .onAppear {
                                    pulseAnimation = true
                                }
                                .allowsHitTesting(false)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 24) {
                        Text(timeString(from: recorder.recordingTime))
                            .font(.system(size: 56, weight: .ultraLight, design: .monospaced))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                            .animation(.smooth, value: recorder.recordingTime)
                        
                        RecordButton(
                            isRecording: recorder.isRecording,
                            isTranscribing: isTranscribing
                        ) {
                            handleRecordButtonTap()
                        }
                        .frame(width: 120, height: 120)
                        .disabled(isTranscribing)
                        
                        Text(statusText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .animation(.smooth, value: statusText)
                    }
                    .padding(.bottom, 60)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingResult) {
                if let result = transcriptionResult {
                    TranscriptionResultView(result: result)
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
    
    private var statusText: String {
        if isTranscribing {
            return "Transkriberar..."
        } else if recorder.isRecording {
            return "Lyssnar..."
        } else {
            return "Tryck för att spela in"
        }
    }
    
    private func handleRecordButtonTap() {
        Task {
            if recorder.isRecording {
                if let audioURL = recorder.stopRecording() {
                    pulseAnimation = false
                    await transcribeAudio(audioURL)
                }
            } else {
                try? await recorder.startRecording()
            }
        }
    }
    
    private func transcribeAudio(_ url: URL) async {
        isTranscribing = true
        defer { isTranscribing = false }
        
        do {
            if whisperService.currentModel == nil {
                try await whisperService.loadModel("kb_whisper-base")
            }
            
            let result = try await whisperService.transcribe(
                audioURL: url,
                language: "sv"
            )
            
            transcriptionResult = result
            showingResult = true
            
            try? FileManager.default.removeItem(at: url)
            
        } catch {
            print("Transcription failed: \(error)")
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        let tenths = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 10)
        return String(format: "%02d:%02d.%d", minutes, seconds, tenths)
    }
}

struct RecordButton: View {
    let isRecording: Bool
    let isTranscribing: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isRecording ? [.red, .red.opacity(0.8)] : [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.8), .white.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: isRecording ? .red.opacity(0.5) : .blue.opacity(0.5), radius: 20)
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                
                if isTranscribing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                } else {
                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .contentTransition(.symbolEffect(.replace))
                }
            }
        }
        .scaleEffect(isRecording ? 1.15 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isRecording)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct WaveformVisualizer: View {
    let levels: [Float]
    let currentLevel: Float
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 3) {
                ForEach(Array(levels.enumerated()), id: \.offset) { index, level in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(0.8),
                                    Color.blue.opacity(0.6)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 4, height: max(4, geometry.size.height * CGFloat(level)))
                        .animation(.smooth(duration: 0.1), value: level)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.03))
            )
        }
    }
}