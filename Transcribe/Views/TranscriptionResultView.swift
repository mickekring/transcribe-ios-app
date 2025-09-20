//
//  TranscriptionResultView.swift
//  Transcribe
//
//  Created by Micke Kring on 2025-09-19.
//

import SwiftUI
import UniformTypeIdentifiers

struct TranscriptionResultView: View {
    let result: TranscriptionResult
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var copiedToClipboard = false
    @State private var selectedSegment: TranscriptionSegment?
    @State private var showSegments = false
    
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
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Transkribering")
                                        .font(.largeTitle.bold())
                                        .foregroundStyle(.white)
                                    
                                    Text(result.formattedTimestamp)
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Label(result.formattedDuration, systemImage: "timer")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.8))
                                    
                                    Label("\(result.wordCount) ord", systemImage: "text.word.spacing")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            if !result.segments.isEmpty {
                                Button(action: { showSegments.toggle() }) {
                                    HStack {
                                        Image(systemName: showSegments ? "chevron.down" : "chevron.right")
                                            .font(.caption)
                                        Text("Visa segment (\(result.segments.count))")
                                            .font(.subheadline)
                                    }
                                    .foregroundStyle(.cyan)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            if showSegments && !result.segments.isEmpty {
                                ForEach(result.segments) { segment in
                                    SegmentCard(segment: segment, isSelected: selectedSegment?.id == segment.id) {
                                        selectedSegment = segment
                                    }
                                }
                            } else {
                                TranscriptionCard(text: result.text) {
                                    copyToClipboard()
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 100)
                }
                
                VStack {
                    Spacer()
                    
                    HStack(spacing: 16) {
                        ActionButton(
                            icon: "doc.on.doc",
                            title: "Kopiera",
                            gradient: [.blue, .cyan]
                        ) {
                            copyToClipboard()
                        }
                        
                        ActionButton(
                            icon: "square.and.arrow.up",
                            title: "Dela",
                            gradient: [.purple, .pink]
                        ) {
                            showShareSheet = true
                        }
                        
                        ActionButton(
                            icon: "xmark",
                            title: "Stäng",
                            gradient: [.gray, .gray.opacity(0.7)]
                        ) {
                            dismiss()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    .background(
                        LinearGradient(
                            colors: [Color.black.opacity(0), Color.black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 150)
                        .offset(y: -50)
                    )
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(text: result.text)
        }
        .overlay(
            copiedNotification
        )
    }
    
    @ViewBuilder
    private var copiedNotification: some View {
        if copiedToClipboard {
            VStack {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Kopierat till urklipp")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                }
                .padding()
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.8))
                        .background(
                            Capsule()
                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                        )
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 50)
                
                Spacer()
            }
            .animation(.spring(), value: copiedToClipboard)
        }
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = result.text
        
        withAnimation {
            copiedToClipboard = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                copiedToClipboard = false
            }
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
}

struct TranscriptionCard: View {
    let text: String
    let onTap: () -> Void
    
    var body: some View {
        Text(text)
            .font(.body)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .onTapGesture(perform: onTap)
    }
}

struct SegmentCard: View {
    let segment: TranscriptionSegment
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(segment.timestamp)
                .font(.caption)
                .foregroundStyle(.cyan.opacity(0.8))
            
            Text(segment.text)
                .font(.body)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.cyan.opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.cyan.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .onTapGesture(perform: onTap)
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let gradient: [Color]
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                Text(title)
                    .font(.caption)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: gradient.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityItems = [text]
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}