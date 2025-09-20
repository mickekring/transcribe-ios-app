//
//  TestView.swift
//  Transcribe
//
//  Created by Micke Kring on 2025-09-19.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "mic.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.cyan)
                
                Text("Transcribe App")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text("Debug Test View")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            print("DEBUG: TestView appeared successfully")
        }
    }
}

#Preview {
    TestView()
}