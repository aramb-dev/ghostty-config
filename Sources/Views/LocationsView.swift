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
                Group {
                    if #available(macOS 14.0, *) {
                        ContentUnavailableView("No Config Found", systemImage: "folder.badge.questionmark", description: Text("Create a config file in one of the locations above to get started."))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "folder.badge.questionmark")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("No Config Found")
                                .font(.headline)
                            Text("Create a config file in one of the locations above to get started.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
            }
        }
        .padding(24)
    }
}
