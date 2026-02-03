import Foundation

struct OptionRegistry {
    static let shared = OptionRegistry()

    let knownOptions: Set<String>

    init() {
        knownOptions = [
            "font-family",
            "background",
            "foreground",
            "theme",
            "window-padding-x",
            "window-padding-y",
            "config-file",
            "keybind"
        ]
    }
}
