import Foundation

struct ConfigDocument: Identifiable {
    let id = UUID()
    let url: URL
    var rawText: String
    var entries: [ConfigEntry]
    var keybindings: [Keybinding]
}

struct ConfigEntry: Identifiable {
    let id = UUID()
    let lineNumber: Int
    let key: String
    let value: String
    let isEmptyValue: Bool
    let rawLine: String
}

struct Keybinding: Identifiable {
    let id = UUID()
    let lineNumber: Int
    let chord: String
    let action: String
    let rawLine: String
}
