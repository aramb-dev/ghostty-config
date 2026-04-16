import SwiftUI

struct LocationsView: View {
    @ObservedObject var store: GhosttyConfigStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Configuration Locations")
                .font(.title2)
                .bold()

            List(store.locations) { location in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.url.path)
                            .font(.system(.body, design: .monospaced))
                        Text(location.exists ? "Found" : "Not found")
                            .font(.caption)
                            .foregroundStyle(location.exists ? .green : .secondary)
                    }
                    Spacer()
                    if location.exists {
                        Button("Use") {
                            store.setActiveConfig(url: location.url)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .listStyle(.inset)

            if store.activeConfigURL == nil {
                ContentUnavailableView("No Config Found", systemImage: "folder.badge.questionmark", description: Text("Create a config file in one of the locations above to get started."))
            }
        }
        .padding(24)
    }
}
