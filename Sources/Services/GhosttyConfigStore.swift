import Foundation
import SwiftUI

@MainActor
final class GhosttyConfigStore: ObservableObject {
    @Published var configEntries: [ConfigEntry] = []
    @Published var keybindingEntries: [KeybindingEntry] = []
    @Published var locations: [ConfigFileLocation] = []
    @Published var validationIssues: [ValidationIssue] = []
    @Published var rawText: String = ""
    @Published var activeConfigURL: URL?
    @Published var configOptionDetails: [ConfigOptionDetail] = []

    private let catalog = GhosttyOptionCatalog.shared

    func load() {
        let fileURLs = locateConfigFiles()
        locations = fileURLs.map { url in
            ConfigFileLocation(url: url, exists: FileManager.default.fileExists(atPath: url.path))
        }

        let existingURL = fileURLs.first(where: { FileManager.default.fileExists(atPath: $0.path) })
        activeConfigURL = existingURL ?? fileURLs.first
        loadActiveConfig()
    }

    func loadActiveConfig() {
        guard let url = activeConfigURL else {
            configEntries = []
            keybindingEntries = []
            validationIssues = []
            configOptionDetails = []
            rawText = ""
            return
        }

        rawText = (try? String(contentsOf: url, encoding: .utf8)) ?? ""
        parse(rawText: rawText, sourcePath: url.path)
    }

    func saveRawText() throws {
        guard let url = activeConfigURL else { return }
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try rawText.write(to: url, atomically: true, encoding: .utf8)
        loadActiveConfig()
    }

    func setActiveConfig(url: URL) {
        activeConfigURL = url
        loadActiveConfig()
    }

    private func locateConfigFiles() -> [URL] {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let xdgHome = ProcessInfo.processInfo.environment["XDG_CONFIG_HOME"].map { URL(fileURLWithPath: $0) }
        let defaultXDG = home.appendingPathComponent(".config", isDirectory: true)
        let xdgRoot = xdgHome ?? defaultXDG

        let xdgPath = xdgRoot.appendingPathComponent("ghostty/config")
        let macPath = home
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
            .appendingPathComponent("com.mitchellh.ghostty", isDirectory: true)
            .appendingPathComponent("config")

        return [macPath, xdgPath]
    }

    private func parse(rawText: String, sourcePath: String) {
        var entries: [ConfigEntry] = []
        var keybindings: [KeybindingEntry] = []
        var issues: [ValidationIssue] = []

        let lines = rawText.components(separatedBy: .newlines)
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }

            let parts = trimmed.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else {
                issues.append(ValidationIssue(
                    severity: .warning,
                    message: "Line could not be parsed as key = value.",
                    sourcePath: sourcePath,
                    lineNumber: index + 1
                ))
                continue
            }

            let key = parts[0].trimmingCharacters(in: .whitespaces)
            var value = parts[1].trimmingCharacters(in: .whitespaces)

            // Strip inline comments (e.g. key = value # comment)
            if let commentRange = value.range(of: "\\s#", options: .regularExpression) {
                value = String(value[..<commentRange.lowerBound]).trimmingCharacters(in: .whitespaces)
            }

            if key == "keybind" {
                let keybindParts = value.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
                if keybindParts.count == 2 {
                    let chord = String(keybindParts[0]).trimmingCharacters(in: .whitespaces)
                    let action = String(keybindParts[1]).trimmingCharacters(in: .whitespaces)
                    keybindings.append(KeybindingEntry(chord: chord, action: action, sourcePath: sourcePath, lineNumber: index + 1))
                    validateKeybinding(action: action, sourcePath: sourcePath, lineNumber: index + 1, issues: &issues)
                } else {
                    issues.append(ValidationIssue(
                        severity: .warning,
                        message: "Invalid keybind format. Expected 'chord=action'.",
                        sourcePath: sourcePath,
                        lineNumber: index + 1
                    ))
                    let chord = value.trimmingCharacters(in: .whitespaces)
                    keybindings.append(KeybindingEntry(chord: chord, action: "", sourcePath: sourcePath, lineNumber: index + 1))
                }
            } else {
                entries.append(ConfigEntry(key: key, value: value, sourcePath: sourcePath, lineNumber: index + 1))
                validateOption(key: key, value: value, sourcePath: sourcePath, lineNumber: index + 1, issues: &issues)
            }
        }

        configEntries = entries
        keybindingEntries = keybindings
        validationIssues = issues

        configOptionDetails = entries.map { entry in
            ConfigOptionDetail(entry: entry, catalogOption: catalog.optionsByKey[entry.key])
        }
    }

    private func validateOption(key: String, value: String, sourcePath: String, lineNumber: Int, issues: inout [ValidationIssue]) {
        guard !catalog.optionKeys.isEmpty else { return }
        if !catalog.optionKeys.contains(key) {
            issues.append(ValidationIssue(
                severity: .warning,
                message: "Unknown option: \(key)",
                sourcePath: sourcePath,
                lineNumber: lineNumber
            ))
            return
        }

        if let option = catalog.optionsByKey[key],
           let validValues = option.validValues,
           !validValues.isEmpty,
           option.type == "enum",
           !value.isEmpty {
            if !validValues.contains(value) {
                issues.append(ValidationIssue(
                    severity: .warning,
                    message: "Invalid value '\(value)' for option '\(key)'. Valid values: \(validValues.joined(separator: ", "))",
                    sourcePath: sourcePath,
                    lineNumber: lineNumber
                ))
            }
        }
    }

    private func validateKeybinding(action: String, sourcePath: String, lineNumber: Int, issues: inout [ValidationIssue]) {
        guard !catalog.actionKeys.isEmpty else { return }
        let actionKey = action.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? action
        guard !actionKey.isEmpty else { return }
        if !catalog.actionKeys.contains(actionKey) {
            issues.append(ValidationIssue(
                severity: .warning,
                message: "Unknown keybinding action: \(actionKey)",
                sourcePath: sourcePath,
                lineNumber: lineNumber
            ))
        }
    }
}
