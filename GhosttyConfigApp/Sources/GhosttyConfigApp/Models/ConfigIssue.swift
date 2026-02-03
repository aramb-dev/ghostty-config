import Foundation

struct ConfigIssue: Identifiable {
    let id = UUID()
    let severity: Severity
    let message: String
    let line: Int?
    let key: String?

    enum Severity: String {
        case info
        case warning
        case error

        var symbolName: String {
            switch self {
            case .info:
                return "info.circle"
            case .warning:
                return "exclamationmark.triangle"
            case .error:
                return "xmark.octagon"
            }
        }
    }
}
