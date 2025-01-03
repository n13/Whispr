import SwiftUI
import WhisperKit

enum WhisprState {
    case waiting
    case recording
    case processing
    case showing
}

class WhisprViewModel: ObservableObject {
    @Published var state: WhisprState = .waiting
    @Published var transcription = ""
    @Published var isRecording = false
    
    // For streaming transcription updates
    func appendTranscription(_ text: String) {
        transcription += text + " "
    }
}

struct ContentView: View {
    @StateObject private var viewModel = WhisprViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    // Custom colors
    let primaryColor = Color("AccentColor", bundle: nil)
    let backgroundColor = Color(.systemBackground)
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Transcription area
                    transcriptionArea
                    
                    // Controls
                    controlsArea
                }
                .padding()
            }
            .navigationTitle("Whispr")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var transcriptionArea: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.state == .waiting && viewModel.transcription.isEmpty {
                    emptyStateView
                } else {
                    Text(viewModel.transcription)
                        .font(.body)
                        .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(radius: 2)
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("Tap the microphone to start recording\nor paste audio from another app")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var controlsArea: some View {
        VStack(spacing: 20) {
            // Main record button
            recordButton
            
            // Action buttons
            if !viewModel.transcription.isEmpty {
                actionButtons
            }
        }
    }
    
    private var recordButton: some View {
        Button(action: {
            withAnimation {
                viewModel.isRecording.toggle()
                viewModel.state = viewModel.isRecording ? .recording : .processing
                if !viewModel.isRecording {
                    // Simulate processing for preview
                    simulateTranscription()
                }
            }
        }) {
            ZStack {
                Circle()
                    .fill(viewModel.isRecording ? Color.red : primaryColor)
                    .frame(width: 80, height: 80)
                    .shadow(radius: 4)
                
                Image(systemName: viewModel.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 24) {
            // Copy button
            Button(action: {
                UIPasteboard.general.string = viewModel.transcription
            }) {
                VStack {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 24))
                    Text("Copy")
                        .font(.caption)
                }
            }
            
            // Paste button
            Button(action: {
                if let text = UIPasteboard.general.string {
                    viewModel.state = .processing
                    // Handle paste action
                }
            }) {
                VStack {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 24))
                    Text("Paste")
                        .font(.caption)
                }
            }
            
            // Share button
            Button(action: {
                // Handle share action
            }) {
                VStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 24))
                    Text("Share")
                        .font(.caption)
                }
            }
        }
        .foregroundColor(primaryColor)
    }
    
    // Preview helper
    private func simulateTranscription() {
        viewModel.transcription = ""
        let words = "This is Whispr, transforming your voice into text..."
            .split(separator: " ")
        
        for (index, word) in words.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                viewModel.appendTranscription(String(word))
                if index == words.count - 1 {
                    viewModel.state = .showing
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
