import SwiftUI

struct ValidationView: View {
    @ObservedObject var store: GhosttyConfigStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Validation")
                .font(.title2)
                .bold()

            if store.validationIssues.isEmpty {
                ContentUnavailableView("No Issues", systemImage: "checkmark.seal", description: Text("Your configuration looks clean."))
            } else {
                List(store.validationIssues) { issue in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: issue.severity == .warning ? "exclamationmark.triangle" : "xmark.octagon")
                            .foregroundStyle(issue.severity == .warning ? .orange : .red)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(issue.message)
                                .font(.headline)
                            Text(issue.sourcePath)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if let line = issue.lineNumber {
                                Text("Line \(line)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.inset)
            }
        }
        .padding(24)
    }
}
