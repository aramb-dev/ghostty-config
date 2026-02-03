import SwiftUI

struct RawConfigView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if let document = appState.loadedConfig {
                CodeEditorView(text: Binding(
                    get: { document.rawText },
                    set: { appState.updateRawText($0) }
                ))
                .frame(minHeight: 320)
                .overlay(alignment: .bottomTrailing) {
                    Button("Save") {
                        appState.saveCurrentConfig()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            } else {
                ContentUnavailableView("No Config Loaded", systemImage: "doc.plaintext")
            }
        }
        .padding()
    }

    private var header: some View {
        VStack(alignment: .leading) {
            Text("Raw Configuration")
                .font(.title2)
            Text("Edit the config file directly with a native AppKit text editor.")
                .foregroundStyle(.secondary)
        }
    }
}
