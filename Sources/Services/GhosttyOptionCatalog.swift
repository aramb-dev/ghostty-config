import Foundation

struct CatalogOption: Decodable, Identifiable, Hashable {
    let key: String
    let description: String
    let type: String
    let defaultValue: String?
    let validValues: [String]?
    let repeatable: Bool
    let platform: String
    let category: String
    let since: String?

    var id: String { key }

    private enum CodingKeys: String, CodingKey {
        case key, description, type
        case defaultValue = "default"
        case validValues, repeatable, platform, category, since
    }
}

struct CatalogAction: Decodable, Identifiable, Hashable {
    let key: String
    let description: String
    let parameter: String?
    let parameterValues: [String]?
    let platform: String

    var id: String { key }
}

struct GhosttyOptionCatalog: Decodable {
    let options: [CatalogOption]
    let actions: [CatalogAction]

    let optionsByKey: [String: CatalogOption]
    let actionsByKey: [String: CatalogAction]
    let optionKeys: Set<String>
    let actionKeys: Set<String>
    let categories: [String]
    let optionsByCategory: [String: [CatalogOption]]

    init(options: [CatalogOption], actions: [CatalogAction]) {
        self.options = options
        self.actions = actions
        self.optionsByKey = Dictionary(uniqueKeysWithValues: options.map { ($0.key, $0) })
        self.actionsByKey = Dictionary(uniqueKeysWithValues: actions.map { ($0.key, $0) })
        self.optionKeys = Set(options.map(\.key))
        self.actionKeys = Set(actions.map(\.key))

        var seen = Set<String>()
        var orderedCategories: [String] = []
        var grouped: [String: [CatalogOption]] = [:]
        for option in options {
            if seen.insert(option.category).inserted {
                orderedCategories.append(option.category)
            }
            grouped[option.category, default: []].append(option)
        }
        self.categories = orderedCategories
        self.optionsByCategory = grouped
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let options = try container.decode([CatalogOption].self, forKey: .options)
        let actions = try container.decode([CatalogAction].self, forKey: .actions)
        self.init(options: options, actions: actions)
    }

    private enum CodingKeys: String, CodingKey {
        case options, actions
    }

    static let shared: GhosttyOptionCatalog = {
        do {
            guard let url = Bundle.main.url(forResource: "ghostty-catalog", withExtension: "json") else {
                fatalError("Missing resource: ghostty-catalog.json")
            }
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(GhosttyOptionCatalog.self, from: data)
        } catch {
            fatalError("Failed to decode ghostty-catalog.json: \(error)")
        }
    }()
}
