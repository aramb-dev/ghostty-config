import Foundation

struct ConfigFileLocator {
    func defaultConfigURL() -> URL? {
        if let xdg = ProcessInfo.processInfo.environment["XDG_CONFIG_HOME"], !xdg.isEmpty {
            let url = URL(fileURLWithPath: xdg).appendingPathComponent("ghostty/config")
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }

        if let home = ProcessInfo.processInfo.environment["HOME"], !home.isEmpty {
            let xdgFallback = URL(fileURLWithPath: home)
                .appendingPathComponent(".config/ghostty/config")
            if FileManager.default.fileExists(atPath: xdgFallback.path) {
                return xdgFallback
            }

            let macPath = URL(fileURLWithPath: home)
                .appendingPathComponent("Library/Application Support/com.mitchellh.ghostty/config")
            if FileManager.default.fileExists(atPath: macPath.path) {
                return macPath
            }
        }

        return nil
    }
}
