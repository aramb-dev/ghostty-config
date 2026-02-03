import Foundation

struct GhosttyOptionCatalog: Decodable {
    let options: [String]
    let keybindingActions: [String]

    static let shared: GhosttyOptionCatalog = {
        guard
            let url = Bundle.main.url(forResource: "ghostty-catalog", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let catalog = try? JSONDecoder().decode(GhosttyOptionCatalog.self, from: data)
        else {
            return GhosttyOptionCatalog(options: [], keybindingActions: [])
        }
        return catalog
    }()
}
