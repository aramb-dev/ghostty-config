# Ghostty Config Companion App - PRD

## Vision

A native macOS companion app for [Ghostty](https://ghostty.org) that gives users a full GUI for browsing, understanding, and editing their Ghostty terminal configuration. Every option is presented with its description, valid values, and sensible defaults so users never have to memorize config syntax. Changes made in the GUI are written back to the user's config file transparently.

## Problem

Ghostty is configured via a plain text file (`key = value` syntax). This works well for power users, but:

- There are 150+ configuration options. Discovering them requires reading docs or running CLI commands.
- There's no autocomplete, validation, or inline help while editing.
- Typos in keys or values silently produce unexpected behavior.
- Some options have complex valid value sets (enums, colors, durations, comma-separated lists) that are hard to remember.
- Keybinding configuration has its own sub-syntax (`trigger=action`) with 50+ actions, modifiers, prefixes, and chord sequences.

## Target User

Anyone using Ghostty who wants to customize their setup without memorizing the reference docs. This includes users migrating from terminals with GUI preferences (iTerm2, Terminal.app) and power users who want faster discovery of lesser-known options.

## Core Principles

1. **Read the real config, write the real config.** The app is not a separate settings store. It reads the user's actual Ghostty config file(s), and every GUI change writes back to that same file.
2. **Full catalog with descriptions.** Every Ghostty option and keybinding action is in the app with its documentation, valid values, defaults, and platform notes.
3. **Native macOS experience.** SwiftUI, system controls, proper keyboard navigation, dark/light mode support.
4. **Non-destructive.** Comments, blank lines, and ordering in the user's config file are preserved when the app writes changes. The app never silently deletes or reorders entries.

---

## Current State

### What's Built

| Component | Status | Notes |
|-----------|--------|-------|
| App shell & sidebar navigation | Done | Overview, Configuration, Keybindings, Validation, Raw Editor, Locations |
| Config file discovery | Done | XDG and macOS Application Support paths |
| Config parser | Done | Parses `key = value`, extracts keybindings, handles comments |
| Validation engine | Done | Warns on unknown keys/actions using catalog |
| Raw text editor | Done | NSTextView-based, monospaced, save-back to file |
| Option catalog (`ghostty-catalog.json`) | Stub | Only 10 options, 24 actions. No descriptions or value types. |
| Programmatic app icon | Done | Ghost + gear, rendered via Core Graphics |
| Reference docs | Done | All 7 Ghostty reference pages converted to markdown |

### What's Missing

| Component | Priority | Description |
|-----------|----------|-------------|
| Full option catalog | P0 | All ~150 options with descriptions, types, defaults, valid values, platform tags |
| Full action catalog | P0 | All ~50 keybinding actions with descriptions |
| GUI editing controls | P0 | Type-appropriate controls per option (see below) |
| Write-back from GUI | P0 | GUI edits update the config file, preserving comments and structure |
| Add new option flow | P1 | Browse all available options, add ones not yet in config |
| Option descriptions in UI | P1 | Show inline docs for each option in the Configuration view |
| Grouped/categorized options | P1 | Organize options into sections (Font, Colors, Window, macOS, etc.) |
| Search across all options | P1 | Search the full catalog, not just options already in config |
| Config file creation | P2 | Create a new config file if none exists |
| Multi-file support | P2 | Handle `config-file` includes, show merged view |
| Theme preview | P2 | Preview color themes before applying |
| Keybinding editor | P2 | Record key combos, pick actions from dropdown |
| Undo/redo for GUI edits | P3 | Standard Cmd+Z support for option changes |
| File watcher | P3 | Detect external config changes and reload |

---

## Catalog Data Model

The current `ghostty-catalog.json` is a flat list of option names. It needs to become a rich catalog:

```json
{
  "options": [
    {
      "key": "font-family",
      "description": "The font families to use.",
      "type": "string",
      "default": null,
      "repeatable": true,
      "runtimeReload": "new-terminal",
      "platform": null,
      "category": "font",
      "since": null
    },
    {
      "key": "cursor-style",
      "description": "The style of the cursor.",
      "type": "enum",
      "default": "block",
      "values": ["block", "bar", "underline", "block_hollow"],
      "repeatable": false,
      "runtimeReload": true,
      "platform": null,
      "category": "cursor",
      "since": null
    },
    {
      "key": "background-opacity",
      "description": "The opacity level of the background.",
      "type": "float",
      "default": 1.0,
      "min": 0.0,
      "max": 1.0,
      "repeatable": false,
      "runtimeReload": "restart",
      "platform": null,
      "category": "opacity",
      "since": null
    }
  ],
  "keybindingActions": [
    {
      "action": "new_window",
      "description": "Open a new window.",
      "parameter": null,
      "platform": null
    },
    {
      "action": "increase_font_size",
      "description": "Increase the font size by the specified amount in points.",
      "parameter": "float",
      "platform": null
    }
  ],
  "categories": [
    { "id": "font", "label": "Font" },
    { "id": "color", "label": "Colors & Theme" },
    { "id": "cursor", "label": "Cursor" },
    { "id": "mouse", "label": "Mouse & Input" },
    { "id": "opacity", "label": "Opacity & Blur" },
    { "id": "window", "label": "Window" },
    { "id": "command", "label": "Command & Environment" },
    { "id": "keybind", "label": "Keybindings" },
    { "id": "shell", "label": "Shell Integration" },
    { "id": "quick-terminal", "label": "Quick Terminal" },
    { "id": "clipboard", "label": "Clipboard" },
    { "id": "macos", "label": "macOS" },
    { "id": "gtk", "label": "GTK / Linux" },
    { "id": "advanced", "label": "Advanced" }
  ]
}
```

### Option Types and GUI Controls

| Type | Control | Examples |
|------|---------|----------|
| `string` | Text field | `font-family`, `title`, `command` |
| `bool` | Toggle | `font-thicken`, `focus-follows-mouse` |
| `enum` | Dropdown / segmented picker | `cursor-style`, `window-theme` |
| `color` | Color well + hex field | `background`, `foreground`, `cursor-color` |
| `float` | Slider + text field | `background-opacity`, `font-size` |
| `int` | Stepper + text field | `window-height`, `scrollback-limit` |
| `duration` | Text field (with format hint) | `resize-overlay-duration`, `undo-timeout` |
| `keybind` | Key recorder + action picker | `keybind` |
| `comma-list` | Tag/chip input | `font-synthetic-style`, `bell-features` |
| `palette` | Grid of 16 color wells | `palette` |

---

## Write-Back Strategy

When a user changes an option via the GUI:

1. **Option exists in config:** Find the line, replace the value, preserve surrounding whitespace and comments.
2. **Option is new:** Append `key = value` at the end of the file (or at the end of the relevant section if we can detect grouping).
3. **Option is reset to default:** Remove the line (or comment it out, user-configurable preference).
4. **Comments and blank lines:** Never modify, delete, or reorder lines the app didn't create.

The raw editor and GUI must stay in sync. If the user edits raw text, the GUI reflects it on next navigation. If the user edits via GUI, the raw text updates immediately.

---

## Roadmap

### Phase 1: Full Catalog + Descriptions (Foundation)

- Build complete `ghostty-catalog.json` from the option-ref.md and keybind-ref.md
- Update `GhosttyOptionCatalog` Swift model to decode the rich schema
- Show descriptions in ConfigurationView alongside current values
- Categorize options in sidebar or grouped list

### Phase 2: GUI Editing Controls

- Implement type-aware editing controls (see table above)
- Wire controls to write-back logic in `GhosttyConfigStore`
- Preserve file structure on write (comments, ordering, whitespace)
- Add "Add Option" flow: browse full catalog, pick an option, set value

### Phase 3: Keybinding Editor

- Full action catalog with descriptions
- Key chord recorder (press keys to capture a trigger)
- Action picker dropdown with search
- Prefix toggles (global, all, unconsumed, performable)

### Phase 4: Polish & Advanced Features

- Theme browser with live preview
- Color palette visual editor (16-color grid)
- File watcher for external changes
- Multi-file / config-file include support
- Config diffing (show what differs from defaults)

---

## Technical Notes

- **Platform:** macOS 13+ (Ventura), Swift Package Manager
- **Framework:** SwiftUI with AppKit bridging where needed (NSTextView for raw editor)
- **Data flow:** `GhosttyConfigStore` (ObservableObject) is the single source of truth
- **Catalog source:** `ghostty-catalog.json` bundled as a Swift package resource, generated from the markdown reference files
- **No network access:** The app is fully offline. No telemetry, no update checks.
