import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationSplitView {
            List(selection: $appState.selection) {
                Section("Configuration") {
                    ForEach(ConfigSection.allCases) { section in
                        Label(section.rawValue, systemImage: iconName(for: section))
                            .tag(section)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220)
            .toolbar {
                ToolbarItemGroup {
                    Button("Open") {
                        appState.openConfigFile()
                    }
                    Button("Save") {
                        appState.saveCurrentConfig()
                    }
                }
            }
        } detail: {
            detailView
        }
        .onAppear {
            if appState.loadedConfig == nil {
                appState.loadDefaultConfig()
            }
        }
    }

    @ViewBuilder
    private var detailView: some View {
        switch appState.selection {
        case .options:
            OptionsView()
        case .keybindings:
            KeybindingsView()
        case .raw:
            RawConfigView()
        case .validation:
            ValidationView()
        }
    }

    private func iconName(for section: ConfigSection) -> String {
        switch section {
        case .options:
            return "slider.horizontal.3"
        case .keybindings:
            return "keyboard"
        case .raw:
            return "doc.plaintext"
        case .validation:
            return "checkmark.seal"
        }
    }
}
