import SwiftUI

struct KeybindingsView: View {
    @ObservedObject var store: GhosttyConfigStore
    @State private var searchText = ""

    var filteredEntries: [KeybindingEntry] {
        guard !searchText.isEmpty else { return store.keybindingEntries }
        return store.keybindingEntries.filter { entry in
            entry.chord.localizedCaseInsensitiveContains(searchText) ||
            entry.action.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Keybindings")
                .font(.title2)
                .bold()

            TextField("Search keybindings", text: $searchText)
                .textFieldStyle(.roundedBorder)

            Table(filteredEntries) {
                TableColumn("Chord") { entry in
                    Text(entry.chord)
                        .font(.system(.body, design: .monospaced))
                }
                TableColumn("Action") { entry in
                    Text(entry.action)
                        .font(.system(.body, design: .monospaced))
                }
                TableColumn("Location") { entry in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.sourcePath)
                            .font(.caption)
                        Text("Line \(entry.lineNumber)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(24)
    }
}
