# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build and Run
- **Build**: `xcodebuild -project Transcribe.xcodeproj -scheme Transcribe -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16 Pro' build`
- **Clean Build**: `xcodebuild -project Transcribe.xcodeproj -scheme Transcribe -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16 Pro' clean build`
- **Run**: Press Cmd+R in Xcode
- **Clean**: `xcodebuild -project Transcribe.xcodeproj -scheme Transcribe clean`

### Testing
- **Run all tests**: `xcodebuild -project Transcribe.xcodeproj -scheme Transcribe -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16 Pro' test`
- **Run unit tests only**: `xcodebuild -project Transcribe.xcodeproj -scheme TranscribeTests -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16 Pro' test`
- **Run UI tests only**: `xcodebuild -project Transcribe.xcodeproj -scheme TranscribeUITests -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16 Pro' test`

### Swift Package Management
- **Resolve dependencies**: `xcodebuild -resolvePackageDependencies -project Transcribe.xcodeproj`
- **Update packages**: Open project in Xcode → File → Packages → Update to Latest Package Versions

## Architecture

### Project Structure
This is a modern SwiftUI-based iOS application for audio transcription using the WhisperKit framework for on-device speech recognition. The app features a beautiful dark theme with cyan accents and is optimized for Swedish language transcription.

**Core Features:**
- Local audio recording and transcription (no internet required)
- KB Whisper models for Swedish-optimized transcription
- Beautiful waveform visualizer during recording
- Transcription history with search
- Model management and settings

**File Structure:**
```
Transcribe/
├── TranscribeApp.swift          # App entry point with setup
├── ContentView.swift            # Tab navigation container
├── Services/
│   ├── WhisperKitService.swift # WhisperKit integration & model management
│   ├── AudioRecorder.swift     # Audio recording with AVAudioSession
│   └── AudioPreprocessor.swift # Audio chunking for large files
├── Views/
│   ├── RecordingView.swift     # Main recording UI with waveform
│   ├── TranscriptionResultView.swift # Results display with sharing
│   ├── HistoryView.swift       # Transcription history browser
│   └── SettingsView.swift      # Model selection & preferences
└── Models/
    └── TranscriptionResult.swift # Data models for transcriptions
```

### Dependencies
The app uses Swift Package Manager with these key dependencies:
- **WhisperKit**: Core transcription engine for on-device speech-to-text (from argmaxinc/WhisperKit)
  - Supports custom model repositories including KB Whisper models
- **Swift Transformers**: Hugging Face transformers for Swift (v0.1.15)
- **Swift Collections**: Apple's collections library (v1.2.1)
- **Swift Argument Parser**: Command line parsing (v1.6.1)
- **Jinja**: Template engine (v1.3.0)

### Key Implementation Details

#### Audio Recording
- Uses AVAudioSession with 16kHz sample rate (optimal for WhisperKit)
- MPEG4 AAC format with mono channel for smaller files
- Real-time audio level monitoring with waveform visualization
- Automatic cleanup of temporary recording files

#### WhisperKit Integration
- Supports both KB Whisper (Swedish) and OpenAI Whisper models
- Custom model repository support: `mickekringai/kb-whisper-coreml`
- Automatic model downloading with progress tracking
- Configurable decoding options for language-specific optimization

#### UI/UX Design
- Dark theme with gradient backgrounds
- Cyan accent color throughout
- Tab-based navigation (Recording, History, Settings)
- SwiftUI with iOS 18.6+ features
- Haptic feedback support
- Swedish-first localization

### Permissions
- **Microphone Access**: Required for audio recording
  - Configured via INFOPLIST_KEY_NSMicrophoneUsageDescription in project.pbxproj
  - Swedish permission message: "Transcribe behöver tillgång till mikrofonen för att spela in ljud för transkribering."

### Build Configuration
- **Deployment Target**: iOS 18.6
- **Swift Version**: 5.0 with modern concurrency features
- **Code Signing**: Automatic with team RW3JS6CR99
- **Bundle ID**: com.mickekring.transcribe.Transcribe
- **Supported Devices**: iPhone and iPad
- **Orientation**: All orientations supported

### Testing Approach
- **Unit Tests**: Uses new Swift Testing framework with @Test attributes
- **UI Tests**: Uses traditional XCTest framework
- Test files import the main module with `@testable import Transcribe`

### Known Issues & Solutions
1. **Info.plist Duplication**: Project uses auto-generated Info.plist. Don't create a manual one.
2. **WhisperKit Dependencies**: Warning messages about missing dependencies are normal and don't affect functionality
3. **Simulator Compatibility**: Use iOS 18.6 simulators for testing (iPhone 16 Pro recommended)

### Development Notes
- Project uses Xcode 26.0 with iOS SDK 26.0
- Swift compilation modes: Debug (-Onone), Release (wholemodule)
- Modern Swift features: Approachable Concurrency, MainActor default isolation
- Environment objects passed to views for state management
- @StateObject for service initialization in ContentView