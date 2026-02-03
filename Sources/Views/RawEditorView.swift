import SwiftUI

struct RawEditorView: View {
    @ObservedObject var store: GhosttyConfigStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Raw Configuration")
                .font(.title2)
                .bold()
            Text("Edit the configuration directly. Saving will re-parse and validate the file.")
                .foregroundStyle(.secondary)

            CodeTextView(text: $store.rawText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(24)
    }
}
