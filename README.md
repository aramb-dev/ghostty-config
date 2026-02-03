# Ghostty Config Companion (macOS)

A native macOS companion app for viewing, editing, validating, and managing Ghostty configuration and keybindings. The UI is SwiftUI-first with AppKit fallbacks for power-user workflows.

## Goals

- **Native macOS experience**: SwiftUI for most UI, AppKit for advanced editing and system integrations.
- **Configuration literacy**: parse Ghostty's `key = value` format, highlight keybindings, and surface validation issues.
- **Safe editing**: allow raw editing in an AppKit-powered editor while keeping a structured view of options.

## Architecture Overview

### SwiftUI (90%)
- **NavigationSplitView** provides a sidebar with sections (Options, Keybindings, Raw, Validation).
- **Tables** display parsed options and keybindings.
- **Validation list** surfaces issues with severity icons.

### AppKit (10%)
- **NSTextView-backed editor** for raw config editing with monospaced font and undo support.

### Core Modules

| Area | Responsibility | Notes |
| --- | --- | --- |
| `ConfigParser` | Parses config into entries and keybindings | Ignores comments and blank lines. |
| `ConfigValidator` | Validates known options and required data | Flags unknown options, missing config-file path. |
| `ConfigFileLocator` | Finds default config in XDG + macOS locations | macOS-specific path supported. |

## Future Enhancements

- Load the full Ghostty option registry from the `+show-config --docs` output.
- Add a keybinding picker with validation against Ghostty's action list.
- Provide diff and merge tools for layered config files.
- Add integration for live-reload (triggering reload_config).

## Development

This project is structured as a SwiftPM executable. Open in Xcode and run on macOS 14+.

```bash
open GhosttyConfigApp/Package.swift
```
