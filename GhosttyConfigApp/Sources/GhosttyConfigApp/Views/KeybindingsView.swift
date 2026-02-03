import SwiftUI

struct KeybindingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            if let document = appState.loadedConfig {
                Table(document.keybindings) {
                    TableColumn("Chord") { binding in
                        Text(binding.chord)
                    }
                    TableColumn("Action") { binding in
                        Text(binding.action)
                    }
                    TableColumn("Line") { binding in
                        Text("\(binding.lineNumber)")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                ContentUnavailableView("No Keybindings", systemImage: "keyboard")
            }
        }
        .padding()
    }

    private var header: some View {
        VStack(alignment: .leading) {
            Text("Ghostty Keybindings")
                .font(.title2)
            Text("Keybindings are read from keybind entries in the config.")
                .foregroundStyle(.secondary)
        }
    }
}
