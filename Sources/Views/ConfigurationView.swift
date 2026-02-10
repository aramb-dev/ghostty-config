import SwiftUI

struct ConfigurationView: View {
    @ObservedObject var store: GhosttyConfigStore
    @State private var searchText = ""

    private var filteredDetails: [ConfigOptionDetail] {
        guard !searchText.isEmpty else { return store.configOptionDetails }
        let query = searchText.lowercased()
        return store.configOptionDetails.filter { detail in
            detail.key.lowercased().contains(query) ||
            detail.value.lowercased().contains(query) ||
            (detail.description?.lowercased().contains(query) ?? false)
        }
    }

    private var groupedByCategory: [(String, [ConfigOptionDetail])] {
        var seen = Set<String>()
        var order: [String] = []
        var groups: [String: [ConfigOptionDetail]] = [:]
        for detail in filteredDetails {
            let cat = detail.category ?? "Uncategorized"
            if seen.insert(cat).inserted {
                order.append(cat)
            }
            groups[cat, default: []].append(detail)
        }
        return order.map { ($0, groups[$0]!) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Configuration Options")
                .font(.title2)
                .bold()

            HStack {
                TextField("Search options or descriptions…", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                Spacer()
                Text("\(filteredDetails.count) option\(filteredDetails.count == 1 ? "" : "s")")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }

            if filteredDetails.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Text("No configured options found")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    if !searchText.isEmpty {
                        Text("Try a different search term")
                            .font(.callout)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(groupedByCategory, id: \.0) { category, details in
                        Section(header: Text(category).font(.headline)) {
                            ForEach(details) { detail in
                                ConfigOptionRow(detail: detail)
                            }
                        }
                    }
                }
                .listStyle(.inset)
            }
        }
        .padding(24)
    }
}

private struct ConfigOptionRow: View {
    let detail: ConfigOptionDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(detail.key)
                    .font(.system(.body, design: .monospaced))
                    .bold()
                Text("=")
                    .foregroundStyle(.secondary)
                    .font(.system(.body, design: .monospaced))
                Text(detail.value.isEmpty ? "(empty)" : detail.value)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(detail.value.isEmpty ? .secondary : .primary)
            }

            if let desc = detail.description {
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 6) {
                if let type = detail.type {
                    BadgePill(text: type, color: .blue)
                }
                if let def = detail.defaultValue {
                    BadgePill(text: "default: \(def)", color: .gray)
                }
                if let platform = detail.platform, platform != "all" {
                    BadgePill(text: platform, color: .orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct BadgePill: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .cornerRadius(4)
    }
}
