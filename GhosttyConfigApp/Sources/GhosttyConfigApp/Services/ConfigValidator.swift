import Foundation

struct ConfigValidator {
    private let registry = OptionRegistry.shared

    func validate(document: ConfigDocument) -> [ConfigIssue] {
        var issues: [ConfigIssue] = []

        for entry in document.entries {
            if !registry.knownOptions.contains(entry.key) {
                issues.append(ConfigIssue(
                    severity: .warning,
                    message: "Unknown option \(entry.key).",
                    line: entry.lineNumber,
                    key: entry.key
                ))
            }

            if entry.key == "config-file" && entry.value.isEmpty {
                issues.append(ConfigIssue(
                    severity: .error,
                    message: "config-file must point to a path.",
                    line: entry.lineNumber,
                    key: entry.key
                ))
            }
        }

        let bindingActions = Set(document.keybindings.map { $0.action })
        if bindingActions.contains("reload_config") == false {
            issues.append(ConfigIssue(
                severity: .info,
                message: "Consider adding a reload_config keybinding for quick refresh.",
                line: nil,
                key: "keybind"
            ))
        }

        return issues
    }
}
