# Transcribe - iOS Audio Transcription App (Prototype)

**⚠️ This is a prototype application. Use as-is for testing and development purposes.**

## Overview

Transcribe is a modern iOS application that provides on-device audio transcription using WhisperKit. The app is optimized for Swedish language transcription and runs entirely offline - no internet connection required.

## Features

- 🎙️ **On-device transcription** - Complete privacy with local processing
- 🇸🇪 **Swedish optimized** - Uses KB Whisper models for accurate Swedish transcription
- 🌊 **Live waveform visualization** - Beautiful audio level display during recording
- 📱 **Modern iOS design** - Dark theme with cyan accents
- 📝 **Transcription history** - Search and browse previous transcriptions
- ⚙️ **Model management** - Choose between different Whisper models

## Requirements

- iOS 18.6 or later
- iPhone or iPad
- Xcode 26.0 or later (for building)

## Quick Start

1. Clone the repository
2. Open `Transcribe.xcodeproj` in Xcode
3. Build and run (Cmd+R)

The app will automatically download the required WhisperKit models on first launch.

## Building from Source

```bash
# Build for simulator
xcodebuild -project Transcribe.xcodeproj -scheme Transcribe \
  -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16 Pro' build

# Run tests
xcodebuild -project Transcribe.xcodeproj -scheme Transcribe \
  -destination 'platform=iOS Simulator,OS=18.6,name=iPhone 16 Pro' test
```

## Technology Stack

- **SwiftUI** - Native iOS UI framework
- **WhisperKit** - On-device speech recognition
- **KB Whisper Models** - Swedish-optimized transcription models
- **AVFoundation** - Audio recording and processing

## Privacy

All transcription happens locally on your device. No audio or text data is sent to external servers.

## License

This is a prototype application provided as-is for testing and development purposes.

## Author

Micke Kring