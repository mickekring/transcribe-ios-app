//
//  HistoryView.swift
//  Transcribe
//
//  Created by Micke Kring on 2025-09-19.
//

import SwiftUI

struct HistoryView: View {
    @State private var transcriptions: [TranscriptionResult] = []
    @State private var searchText = ""
    @State private var selectedTranscription: TranscriptionResult?
    
    var filteredTranscriptions: [TranscriptionResult] {
        if searchText.isEmpty {
            return transcriptions
        } else {
            return transcriptions.filter { $0.text.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.08),
                        Color.black
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if transcriptions.isEmpty {
                    emptyStateView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredTranscriptions) { transcription in
                                HistoryCard(transcription: transcription) {
                                    selectedTranscription = transcription
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding()
                        .searchable(text: $searchText, prompt: "Sök transkriberingar")
                    }
                }
            }
            .navigationTitle("Historik")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedTranscription) { transcription in
                TranscriptionResultView(result: transcription)
            }
            .onAppear {
                loadTranscriptions()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("Ingen historik")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                
                Text("Dina transkriberingar kommer att visas här")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
    
    private func loadTranscriptions() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let transcriptionsPath = documentsPath.appendingPathComponent("Transcriptions")
        
        do {
            try FileManager.default.createDirectory(at: transcriptionsPath, withIntermediateDirectories: true)
            
            let files = try FileManager.default.contentsOfDirectory(at: transcriptionsPath, includingPropertiesForKeys: nil)
            let jsonFiles = files.filter { $0.pathExtension == "json" }
            
            transcriptions = jsonFiles.compactMap { url in
                guard let data = try? Data(contentsOf: url),
                      let transcription = try? JSONDecoder().decode(TranscriptionResult.self, from: data) else {
                    return nil
                }
                return transcription
            }
            .sorted { $0.timestamp > $1.timestamp }
        } catch {
            print("Failed to load transcriptions: \(error)")
        }
    }
}

struct HistoryCard: View {
    let transcription: TranscriptionResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(transcription.formattedTimestamp)
                            .font(.caption)
                            .foregroundStyle(.cyan)
                        
                        Text(transcription.text)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.3))
                        
                        Text(transcription.formattedDuration)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                
                HStack(spacing: 16) {
                    Label("\(transcription.wordCount) ord", systemImage: "text.word.spacing")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                    
                    if transcription.language != "unknown" {
                        Label(transcription.language.uppercased(), systemImage: "globe")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}