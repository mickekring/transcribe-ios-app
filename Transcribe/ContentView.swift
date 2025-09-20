//
//  ContentView.swift
//  Transcribe
//
//  Created by Micke Kring on 2025-09-19.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var whisperService = WhisperKitService()
    @StateObject private var audioRecorder = AudioRecorder()
    
    init() {
        print("DEBUG: ContentView init")
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RecordingView()
                .environmentObject(audioRecorder)
                .environmentObject(whisperService)
                .tabItem {
                    Label("Inspelning", systemImage: "mic.fill")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Label("Historik", systemImage: "clock.arrow.circlepath")
                }
                .tag(1)
            
            SettingsView()
                .environmentObject(whisperService)
                .tabItem {
                    Label("Inställningar", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(.cyan)
        .preferredColorScheme(.dark)
        .onAppear {
            print("DEBUG: TabView appeared")
            setupTabBarAppearance()
            // Disabled auto-loading for now
            // loadDefaultModel()
        }
    }
    
    private func setupTabBarAppearance() {
        print("DEBUG: Setting up tab bar appearance")
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(white: 0.05, alpha: 0.95)
        
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.systemCyan
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemCyan]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func loadDefaultModel() {
        print("DEBUG: Loading default model")
        Task {
            if whisperService.currentModel == nil {
                print("DEBUG: No current model, loading kb_whisper-base")
                do {
                    try await whisperService.loadModel("kb_whisper-base")
                    print("DEBUG: Model loaded successfully")
                } catch {
                    print("DEBUG: Failed to load model: \(error)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
