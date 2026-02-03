import SwiftUI

struct OverviewView: View {
    @ObservedObject var store: GhosttyConfigStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ghostty Companion")
                .font(.largeTitle)
                .bold()
            Text("Review, edit, validate, and manage Ghostty configuration files and keybindings.")
                .font(.title3)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                SummaryCard(title: "Options", value: "\(store.configEntries.count)", systemImage: "slider.horizontal.3")
                SummaryCard(title: "Keybindings", value: "\(store.keybindingEntries.count)", systemImage: "keyboard")
                SummaryCard(title: "Warnings", value: "\(store.validationIssues.count)", systemImage: "exclamationmark.triangle")
            }

            if let url = store.activeConfigURL {
                Text("Active Config: \(url.path)")
                    .font(.callout)
            } else {
                Text("No configuration file selected.")
                    .font(.callout)
            }

            Spacer()
        }
        .padding(24)
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.headline)
            Text(value)
                .font(.largeTitle)
                .bold()
        }
        .padding(16)
        .frame(maxWidth: 200, alignment: .leading)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2))
        )
    }
}
