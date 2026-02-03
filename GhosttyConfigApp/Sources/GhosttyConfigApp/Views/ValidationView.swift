import SwiftUI

struct ValidationView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            if appState.validationResults.isEmpty {
                ContentUnavailableView("No Validation Issues", systemImage: "checkmark.seal")
            } else {
                List(appState.validationResults) { issue in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: issue.severity.symbolName)
                            .foregroundStyle(color(for: issue.severity))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(issue.message)
                                .font(.headline)
                            if let line = issue.line {
                                Text("Line \(line)")
                                    .foregroundStyle(.secondary)
                            }
                            if let key = issue.key {
                                Text("Key: \(key)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.inset)
            }
        }
        .padding()
    }

    private var header: some View {
        VStack(alignment: .leading) {
            Text("Validation")
                .font(.title2)
            Text("Review warnings and errors detected in the config.")
                .foregroundStyle(.secondary)
        }
    }

    private func color(for severity: ConfigIssue.Severity) -> Color {
        switch severity {
        case .info:
            return .blue
        case .warning:
            return .orange
        case .error:
            return .red
        }
    }
}
