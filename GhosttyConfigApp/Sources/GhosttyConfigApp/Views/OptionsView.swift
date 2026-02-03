import SwiftUI

struct OptionsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            if let document = appState.loadedConfig {
                Table(document.entries) {
                    TableColumn("Key") { entry in
                        Text(entry.key)
                    }
                    TableColumn("Value") { entry in
                        Text(entry.isEmptyValue ? "(default)" : entry.value)
                            .foregroundStyle(entry.isEmptyValue ? .secondary : .primary)
                    }
                    TableColumn("Line") { entry in
                        Text("\(entry.lineNumber)")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                ContentUnavailableView("No Config Loaded", systemImage: "doc.badge.gearshape")
            }
        }
        .padding()
    }

    private var header: some View {
        VStack(alignment: .leading) {
            Text("Ghostty Options")
                .font(.title2)
            Text("Review parsed configuration keys and values. Empty values reset to defaults.")
                .foregroundStyle(.secondary)
        }
    }
}
