import Foundation

struct ConfigParser {
    func parse(contents: String, url: URL) -> ConfigDocument {
        var entries: [ConfigEntry] = []
        var keybindings: [Keybinding] = []

        let lines = contents.split(whereSeparator: \.isNewline)
        for (index, line) in lines.enumerated() {
            let lineNumber = index + 1
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }

            if trimmed.hasPrefix("keybind") {
                if let binding = parseKeybinding(trimmed, lineNumber: lineNumber, rawLine: String(line)) {
                    keybindings.append(binding)
                }
                continue
            }

            if let entry = parseEntry(trimmed, lineNumber: lineNumber, rawLine: String(line)) {
                entries.append(entry)
            }
        }

        return ConfigDocument(url: url, rawText: contents, entries: entries, keybindings: keybindings)
    }

    private func parseEntry(_ line: String, lineNumber: Int, rawLine: String) -> ConfigEntry? {
        let components = line.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
        guard components.count == 2 else { return nil }
        let key = String(components[0])
        let value = String(components[1]).trimmingCharacters(in: CharacterSet(charactersIn: "\""))
        let isEmpty = components[1].isEmpty
        return ConfigEntry(
            lineNumber: lineNumber,
            key: key,
            value: value,
            isEmptyValue: isEmpty,
            rawLine: rawLine
        )
    }

    private func parseKeybinding(_ line: String, lineNumber: Int, rawLine: String) -> Keybinding? {
        let components = line.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
        guard components.count == 2 else { return nil }
        let bindingValue = components[1]
        let parts = bindingValue.split(separator: "=", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 2 else { return nil }
        return Keybinding(
            lineNumber: lineNumber,
            chord: String(parts[0]),
            action: String(parts[1]),
            rawLine: rawLine
        )
    }
}
