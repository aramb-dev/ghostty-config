import Foundation

struct ConfigEntry: Identifiable, Hashable {
    let id: UUID
    var key: String
    var value: String
    var sourcePath: String
    var lineNumber: Int

    init(key: String, value: String, sourcePath: String, lineNumber: Int) {
        self.id = UUID()
        self.key = key
        self.value = value
        self.sourcePath = sourcePath
        self.lineNumber = lineNumber
    }
}

struct KeybindingEntry: Identifiable, Hashable {
    let id: UUID
    var chord: String
    var action: String
    var sourcePath: String
    var lineNumber: Int

    init(chord: String, action: String, sourcePath: String, lineNumber: Int) {
        self.id = UUID()
        self.chord = chord
        self.action = action
        self.sourcePath = sourcePath
        self.lineNumber = lineNumber
    }
}

struct ConfigFileLocation: Identifiable, Hashable {
    let id: UUID
    var url: URL
    var exists: Bool

    init(url: URL, exists: Bool) {
        self.id = UUID()
        self.url = url
        self.exists = exists
    }
}

struct ValidationIssue: Identifiable, Hashable {
    enum Severity: String {
        case warning
        case error
    }

    let id: UUID
    var severity: Severity
    var message: String
    var sourcePath: String
    var lineNumber: Int?

    init(severity: Severity, message: String, sourcePath: String, lineNumber: Int? = nil) {
        self.id = UUID()
        self.severity = severity
        self.message = message
        self.sourcePath = sourcePath
        self.lineNumber = lineNumber
    }
}
