import SwiftUI

struct ConfigurationView: View {
    @ObservedObject var store: GhosttyConfigStore
    @State private var searchText = ""

    var filteredEntries: [ConfigEntry] {
        guard !searchText.isEmpty else { return store.configEntries }
        return store.configEntries.filter { entry in
            entry.key.localizedCaseInsensitiveContains(searchText) ||
            entry.value.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Configuration Options")
                .font(.title2)
                .bold()

            HStack {
                TextField("Search options", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                Spacer()
            }

            Table(filteredEntries) {
                TableColumn("Key") { entry in
                    Text(entry.key)
                        .font(.system(.body, design: .monospaced))
                }
                TableColumn("Value") { entry in
                    Text(entry.value.isEmpty ? "(default)" : entry.value)
                        .foregroundStyle(entry.value.isEmpty ? .secondary : .primary)
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
