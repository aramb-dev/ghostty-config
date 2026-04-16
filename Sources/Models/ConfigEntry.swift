import Foundation

struct ConfigEntry: Identifiable, Hashable {
    let id: UUID = UUID()
    var key: String
    var value: String
    var sourcePath: String
    var lineNumber: Int

    static func == (lhs: ConfigEntry, rhs: ConfigEntry) -> Bool {
        lhs.key == rhs.key &&
        lhs.value == rhs.value &&
        lhs.sourcePath == rhs.sourcePath &&
        lhs.lineNumber == rhs.lineNumber
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
        hasher.combine(value)
        hasher.combine(sourcePath)
        hasher.combine(lineNumber)
    }
}

struct KeybindingEntry: Identifiable, Hashable {
    let id: UUID = UUID()
    var chord: String
    var action: String
    var sourcePath: String
    var lineNumber: Int

    static func == (lhs: KeybindingEntry, rhs: KeybindingEntry) -> Bool {
        lhs.chord == rhs.chord &&
        lhs.action == rhs.action &&
        lhs.sourcePath == rhs.sourcePath &&
        lhs.lineNumber == rhs.lineNumber
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(chord)
        hasher.combine(action)
        hasher.combine(sourcePath)
        hasher.combine(lineNumber)
    }
}

struct ConfigFileLocation: Identifiable, Hashable {
    let id: UUID = UUID()
    var url: URL
    var exists: Bool
}

struct ValidationIssue: Identifiable, Hashable {
    enum Severity: String {
        case warning
        case error
    }

    let id: UUID = UUID()
    var severity: Severity
    var message: String
    var sourcePath: String
    var lineNumber: Int?
}

struct ConfigOptionDetail: Identifiable, Hashable {
    let id: UUID
    let key: String
    let value: String
    let description: String?
    let type: String?
    let defaultValue: String?
    let validValues: [String]?
    let category: String?
    let platform: String?
    let sourcePath: String
    let lineNumber: Int

    init(entry: ConfigEntry, catalogOption: CatalogOption?) {
        self.id = entry.id
        self.key = entry.key
        self.value = entry.value
        self.description = catalogOption?.description
        self.type = catalogOption?.type
        self.defaultValue = catalogOption?.defaultValue
        self.validValues = catalogOption?.validValues
        self.category = catalogOption?.category
        self.platform = catalogOption?.platform
        self.sourcePath = entry.sourcePath
        self.lineNumber = entry.lineNumber
    }
}
