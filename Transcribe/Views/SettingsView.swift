//
//  SettingsView.swift
//  Transcribe
//
//  Created by Micke Kring on 2025-09-19.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var whisperService: WhisperKitService
    @AppStorage("selectedModel") private var selectedModel = "kb_whisper-base"
    @AppStorage("autoDetectLanguage") private var autoDetectLanguage = false
    @AppStorage("defaultLanguage") private var defaultLanguage = "sv"
    @AppStorage("saveTranscriptions") private var saveTranscriptions = true
    @AppStorage("hapticFeedback") private var hapticFeedback = true
    
    @State private var isLoadingModel = false
    @State private var loadingError: String?
    
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        modelSection
                        languageSection
                        generalSection
                        aboutSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Inställningar")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
    }
    
    @ViewBuilder
    private var modelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "AI-modell", icon: "cpu")
            
            VStack(spacing: 12) {
                ForEach(whisperService.modelOptions) { model in
                    ModelRow(
                        model: model,
                        isSelected: selectedModel == model.id,
                        isCurrentlyLoaded: whisperService.currentModel == model.id,
                        isLoading: isLoadingModel && selectedModel == model.id
                    ) {
                        selectModel(model.id)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            if let error = loadingError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }
            
            if whisperService.isLoading {
                ProgressView(value: whisperService.downloadProgress) {
                    Text("Laddar ner modell...")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .progressViewStyle(LinearProgressViewStyle(tint: .cyan))
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Språk", icon: "globe")
            
            VStack(spacing: 16) {
                ToggleRow(
                    title: "Automatisk språkidentifiering",
                    isOn: $autoDetectLanguage,
                    icon: "text.badge.checkmark"
                )
                
                if !autoDetectLanguage {
                    HStack {
                        Label("Standardspråk", systemImage: "character.bubble")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Picker("", selection: $defaultLanguage) {
                            Text("Svenska").tag("sv")
                            Text("English").tag("en")
                            Text("Norsk").tag("no")
                            Text("Dansk").tag("da")
                            Text("Suomi").tag("fi")
                        }
                        .pickerStyle(.menu)
                        .tint(.cyan)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.03))
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    @ViewBuilder
    private var generalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Allmänt", icon: "gearshape")
            
            VStack(spacing: 16) {
                ToggleRow(
                    title: "Spara transkriberingar",
                    isOn: $saveTranscriptions,
                    icon: "folder"
                )
                
                ToggleRow(
                    title: "Haptisk feedback",
                    isOn: $hapticFeedback,
                    icon: "hand.tap"
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    @ViewBuilder
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Om", icon: "info.circle")
            
            VStack(spacing: 16) {
                InfoRow(title: "Version", value: "1.0.0")
                InfoRow(title: "Bygge", value: "2025.09.19")
                
                Link(destination: URL(string: "https://github.com/mickekringai")!) {
                    HStack {
                        Label("GitHub", systemImage: "link")
                            .font(.subheadline)
                            .foregroundStyle(.cyan)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.cyan.opacity(0.6))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cyan.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    private func selectModel(_ modelId: String) {
        selectedModel = modelId
        
        Task {
            isLoadingModel = true
            loadingError = nil
            
            do {
                try await whisperService.loadModel(modelId)
            } catch {
                loadingError = error.localizedDescription
            }
            
            isLoadingModel = false
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.cyan)
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 4)
    }
}

struct ModelRow: View {
    let model: ModelOption
    let isSelected: Bool
    let isCurrentlyLoaded: Bool
    let isLoading: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.name)
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                    HStack(spacing: 8) {
                        Text(model.size)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                        if let language = model.language {
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.3))
                            Text(language.uppercased())
                                .font(.caption.bold())
                                .foregroundStyle(.cyan.opacity(0.8))
                        }
                    }
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                        .scaleEffect(0.8)
                } else if isCurrentlyLoaded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else if isSelected {
                    Image(systemName: "circle.fill")
                        .foregroundStyle(.cyan)
                        .font(.caption)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.white.opacity(0.3))
                        .font(.caption)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.cyan.opacity(0.1) : Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.cyan.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .disabled(isLoading)
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    
    var body: some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .foregroundStyle(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(.cyan)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
        )
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
        )
    }
}