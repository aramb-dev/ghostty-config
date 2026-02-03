import AppKit
import Combine
import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published private(set) var loadedConfig: ConfigDocument?
    @Published var validationResults: [ConfigIssue] = []
    @Published var selection: ConfigSection = .options

    private let locator = ConfigFileLocator()
    private let parser = ConfigParser()
    private let validator = ConfigValidator()

    func loadDefaultConfig() {
        if let url = locator.defaultConfigURL() {
            loadConfig(from: url)
        }
    }

    func openConfigFile() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["config", "conf", "txt", ""]
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            loadConfig(from: url)
        }
    }

    func loadConfig(from url: URL) {
        do {
            let contents = try String(contentsOf: url)
            let document = parser.parse(contents: contents, url: url)
            loadedConfig = document
            validationResults = validator.validate(document: document)
        } catch {
            loadedConfig = nil
            validationResults = [
                ConfigIssue(
                    severity: .error,
                    message: "Failed to load config: \(error.localizedDescription)",
                    line: nil,
                    key: nil
                )
            ]
        }
    }

    func saveCurrentConfig() {
        guard let document = loadedConfig else { return }
        do {
            try document.rawText.write(to: document.url, atomically: true, encoding: .utf8)
            validationResults = validator.validate(document: document)
        } catch {
            validationResults = [
                ConfigIssue(
                    severity: .error,
                    message: "Failed to save config: \(error.localizedDescription)",
                    line: nil,
                    key: nil
                )
            ]
        }
    }

    func updateRawText(_ text: String) {
        guard var document = loadedConfig else { return }
        document.rawText = text
        let updated = parser.parse(contents: text, url: document.url)
        loadedConfig = updated
        validationResults = validator.validate(document: updated)
    }
}

enum ConfigSection: String, CaseIterable, Identifiable {
    case options = "Options"
    case keybindings = "Keybindings"
    case raw = "Raw"
    case validation = "Validation"

    var id: String { rawValue }
}
