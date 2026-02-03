import SwiftUI

struct ContentView: View {
    @StateObject private var store = GhosttyConfigStore()
    @State private var selection: SidebarSection = .overview
    @State private var showingSaveAlert = false
    @State private var saveErrorMessage = ""

    var body: some View {
        NavigationSplitView {
            List(SidebarSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.systemImage)
            }
            .frame(minWidth: 200)
        } detail: {
            Group {
                switch selection {
                case .overview:
                    OverviewView(store: store)
                case .configuration:
                    ConfigurationView(store: store)
                case .keybindings:
                    KeybindingsView(store: store)
                case .validation:
                    ValidationView(store: store)
                case .rawEditor:
                    RawEditorView(store: store)
                case .locations:
                    LocationsView(store: store)
                }
            }
            .frame(minWidth: 700, minHeight: 480)
            .toolbar {
                ToolbarItemGroup {
                    Button("Reload") {
                        store.loadActiveConfig()
                    }
                    Button("Save") {
                        do {
                            try store.saveRawText()
                        } catch {
                            saveErrorMessage = error.localizedDescription
                            showingSaveAlert = true
                        }
                    }
                }
            }
            .alert("Unable to Save", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(saveErrorMessage)
            }
        }
        .onAppear {
            store.load()
        }
    }
}

enum SidebarSection: String, CaseIterable, Identifiable {
    case overview
    case configuration
    case keybindings
    case validation
    case rawEditor
    case locations

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .configuration: return "Configuration"
        case .keybindings: return "Keybindings"
        case .validation: return "Validation"
        case .rawEditor: return "Raw Editor"
        case .locations: return "Locations"
        }
    }

    var systemImage: String {
        switch self {
        case .overview: return "sparkles"
        case .configuration: return "slider.horizontal.3"
        case .keybindings: return "keyboard"
        case .validation: return "checkmark.seal"
        case .rawEditor: return "doc.plaintext"
        case .locations: return "folder"
        }
    }
}
