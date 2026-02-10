import SwiftUI

struct OptionBrowserView: View {
    @ObservedObject var store: GhosttyConfigStore
    @State private var searchText = ""
    @State private var selectedCategory = "All"

    private let catalog = GhosttyOptionCatalog.shared

    private var categoryChoices: [String] {
        ["All"] + catalog.categories
    }

    private var configuredKeys: Set<String> {
        Set(store.configEntries.map(\.key))
    }

    private var configuredValues: [String: String] {
        Dictionary(store.configEntries.map { ($0.key, $0.value) }, uniquingKeysWith: { _, last in last })
    }

    private var filteredOptions: [CatalogOption] {
        var options = catalog.options
        if selectedCategory != "All" {
            options = options.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            options = options.filter {
                $0.key.lowercased().contains(query) ||
                $0.description.lowercased().contains(query) ||
                $0.category.lowercased().contains(query)
            }
        }
        return options
    }

    private var groupedOptions: [(String, [CatalogOption])] {
        var seen = Set<String>()
        var order: [String] = []
        var groups: [String: [CatalogOption]] = [:]
        for option in filteredOptions {
            if seen.insert(option.category).inserted {
                order.append(option.category)
            }
            groups[option.category, default: []].append(option)
        }
        return order.map { ($0, groups[$0]!) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Options")
                .font(.title2)
                .bold()

            HStack {
                TextField("Search all options…", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                Picker("Category", selection: $selectedCategory) {
                    ForEach(categoryChoices, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
                .frame(width: 200)

                Spacer()
                Text("\(filteredOptions.count) option\(filteredOptions.count == 1 ? "" : "s")")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }

            if filteredOptions.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Text("No options match your search")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                List {
                    ForEach(groupedOptions, id: \.0) { category, options in
                        Section(header: Text(category).font(.headline)) {
                            ForEach(options) { option in
                                CatalogOptionRow(
                                    option: option,
                                    isConfigured: configuredKeys.contains(option.key),
                                    currentValue: configuredValues[option.key]
                                )
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

private struct CatalogOptionRow: View {
    let option: CatalogOption
    let isConfigured: Bool
    let currentValue: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(option.key)
                    .font(.system(.body, design: .monospaced))
                    .bold()

                Spacer()

                if isConfigured {
                    Text(currentValue ?? "")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)

                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                } else {
                    Text("not set")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Text(option.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            HStack(spacing: 6) {
                CatalogBadge(text: option.type, color: .blue)

                if let def = option.defaultValue {
                    CatalogBadge(text: "default: \(def)", color: .gray)
                }

                if option.platform != "all" {
                    CatalogBadge(text: option.platform, color: .orange)
                }

                if option.repeatable {
                    CatalogBadge(text: "repeatable", color: .purple)
                }

                if let since = option.since {
                    CatalogBadge(text: "since \(since)", color: .teal)
                }
            }

            if let validValues = option.validValues, !validValues.isEmpty {
                HStack(spacing: 2) {
                    Text("Values:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(validValues.joined(separator: ", "))
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

private struct CatalogBadge: View {
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
