# Option Reference

Reference of all Ghostty configuration options.

This is a reference of all Ghostty configuration options. These options are ordered roughly by how common they are to be used and grouped with related options.

---

## Font Options

### `font-family` / `font-family-bold` / `font-family-italic` / `font-family-bold-italic`

The font families to use.

You can generate the list of valid values using the CLI:

```
ghostty +list-fonts
```

This configuration can be repeated multiple times to specify preferred fallback fonts when the requested codepoint is not available in the primary font. This is particularly useful for multiple languages, symbolic fonts, etc.

Notes on emoji specifically: On macOS, Ghostty by default will always use Apple Color Emoji and on Linux will always use Noto Emoji. You can override this behavior by specifying a font family here that contains emoji glyphs.

The specific styles (bold, italic, bold italic) do not need to be explicitly set. If a style is not set, then the regular style (`font-family`) will be searched for stylistic variants. If a stylistic variant is not found, Ghostty will use the regular style. This prevents falling back to a different font family just to get a style such as bold.

Finally, some styles may be synthesized if they are not supported. You can disable styles completely by using the `font-style` set of configurations.

If you want to overwrite a previous set value rather than append a fallback, specify the value as `""` (empty string) to reset the list and then set the new values:

```
font-family = ""
font-family = "My Favorite Font"
```

Changing this configuration at runtime will only affect new terminals.

### `font-style` / `font-style-bold` / `font-style-italic` / `font-style-bold-italic`

The named font style to use for each of the requested terminal font styles. This looks up the style based on the font style string advertised by the font itself. For example, "Iosevka Heavy" has a style of "Heavy".

You can also set the value to literal `false` to completely disable a font style.

These are only valid if the corresponding `font-family` is also specified.

### `font-synthetic-style`

Control whether Ghostty should synthesize a style if the requested style is not available in the specified `font-family`.

Ghostty can synthesize bold, italic, and bold italic styles. For bold, this is done by drawing an outline around the glyph. For italic, this is done by applying a slant.

Set this to `false` or `true` to disable or enable synthetic styles completely. You can disable specific styles using `no-bold`, `no-italic`, and `no-bold-italic`. Multiple values can be separated with a comma.

> **Warning:** An easy mistake is to disable bold or italic but not bold-italic. Disabling only bold or italic will NOT disable either in the bold-italic style. You must explicitly disable `bold-italic`.

Default: enabled.

### `font-feature`

Apply a font feature. Can be repeated or use a comma-separated list.

Syntax:
- Enable: `feat`, `+feat`, `feat on`, `feat=1`
- Disable: `-feat`, `feat off`, `feat=0`
- Set value: `feat=2`

To disable programming ligatures: `-calt`. To disable most ligatures: `-calt, -liga, -dlig`.

### `font-size`

Font size in points. Can be a non-integer. For example, `13.5pt @ 2px/pt = 27px`.

Changing this at runtime only affects new terminals. See also `window-inherit-font-size`.

### `font-variation` / `font-variation-bold` / `font-variation-italic` / `font-variation-bold-italic`

Set font variation values for a variable font. Format: `id=value` where `id` is a 4-character axis identifier (e.g., `wght`, `slnt`, `ital`, `opsz`, `wdth`).

### `font-codepoint-map`

Force Unicode codepoints to map to a specific named font. Syntax: `U+ABCD=fontname` or `U+ABCD-U+DEFG=fontname`. Multiple ranges can be comma-separated.

Changing this at runtime only affects new terminals.

### `font-thicken`

Draw fonts with a thicker stroke, if supported. Currently only supported on macOS.

### `font-thicken-strength`

Strength of thickening (0-255). 0 corresponds to the lightest available thickening. Only effective when `font-thicken` is enabled. macOS only.

### `font-shaping-break`

Locations to break font shaping into multiple runs. Combine values with a comma; prefix with `no-` to disable.

Available options:
- `cursor` -- Break runs under the cursor.

*Available since: 1.2.0*

### `alpha-blending`

Color space for alpha blending. Affects text appearance and transparent images.

Valid values:
- `native` -- Native color space (Display P3 on macOS, sRGB on Linux). Default on macOS.
- `linear` -- Linear space. Eliminates darkening artifacts but makes dark text thinner.
- `linear-corrected` -- Linear with correction for text. Default on non-macOS platforms.

*Available since: 1.1.0*

---

## Cell & Metric Adjustments

### `adjust-cell-width` / `adjust-cell-height`

Adjust cell dimensions. Values can be integers (`1`, `-1`) or percentages (`20%`, `-15%`). Values represent changes relative to the original.

`adjust-cell-height` additional behaviors: font centered vertically, cursor unchanged (see `adjust-cursor-height`), powerline glyphs adjusted.

### `adjust-font-baseline`

Distance from the bottom of the cell to the text baseline. Increase to move baseline UP.

### `adjust-underline-position` / `adjust-underline-thickness`

Underline position (from top of cell) and thickness adjustments.

### `adjust-strikethrough-position` / `adjust-strikethrough-thickness`

Strikethrough position and thickness adjustments.

### `adjust-overline-position` / `adjust-overline-thickness`

Overline position and thickness adjustments.

### `adjust-cursor-thickness` / `adjust-cursor-height`

Cursor thickness (bar and outlined rect) and height adjustments.

### `adjust-box-thickness`

Box drawing character thickness adjustment.

### `adjust-icon-height`

Maximum height for nerd font icons. Default is 1.2x the capital letter height.

*Available since: 1.2.0*

### `grapheme-width-method`

Method for calculating grapheme cluster cell width.

Valid values:
- `legacy` -- Use `wcswidth`-like method. Maximizes compatibility.
- `unicode` -- Use Unicode standard. Correct but may desync with some programs.

If terminal mode 2027 is enabled by a program, `unicode` is forced regardless of this setting.

### `freetype-load-flags`

FreeType load flags (Linux only). Comma-separated list.

Available flags: `hinting` (default: on), `force-autohint` (default: off), `monochrome` (default: off), `autohint` (default: on).

---

## Theme & Colors

### `theme`

A theme to use. Can be a built-in theme name, custom theme name, or absolute path.

For light/dark mode: `light:theme-name,dark:theme-name`.

Themes are searched in:
1. `$XDG_CONFIG_HOME/ghostty/themes`
2. `$PREFIX/share/ghostty/themes`

List themes with `ghostty +list-themes`.

### `background` / `foreground`

Window background/foreground color. Specified as hex (`#RRGGBB` or `RRGGBB`) or a named X11 color.

### `background-image`

Path to a PNG or JPEG background image for the terminal.

> **Warning:** Background images are duplicated in VRAM per-terminal.

*Available since: 1.2.0*

### `background-image-opacity`

Background image opacity relative to `background-opacity`. Default: `1.0`.

*Available since: 1.2.0*

### `background-image-position`

Valid values: `top-left`, `top-center`, `top-right`, `center-left`, `center` (default), `center-right`, `bottom-left`, `bottom-center`, `bottom-right`.

*Available since: 1.2.0*

### `background-image-fit`

Valid values: `contain` (default), `cover`, `stretch`, `none`.

*Available since: 1.2.0*

### `background-image-repeat`

Whether to tile the background image. Default: `false`.

*Available since: 1.2.0*

### `selection-foreground` / `selection-background`

Selection colors. Can also be set to `cell-foreground` or `cell-background` (since 1.2.0).

### `selection-clear-on-typing`

Clear selection when typing. Default: `true`.

*Available since: 1.2.0*

### `selection-clear-on-copy`

Clear selection after copying. Default: `false`.

### `minimum-contrast`

Minimum contrast ratio (1-21) between foreground and background. Does not apply to emoji or images.

### `palette`

Color palette (0-255). Syntax: `N=COLOR` (e.g., `0=#AABBCC`).

### `cursor-color`

Cursor color. Supports hex, X11 color names, `cell-foreground`, or `cell-background`.

### `cursor-opacity`

Cursor opacity (0.0 to 1.0).

### `cursor-style`

Default cursor style. Valid values: `block`, `bar`, `underline`, `block_hollow`.

### `cursor-style-blink`

Default cursor blink state. Values: `true`, `false`, or blank (null, respects DEC Mode 12).

### `cursor-text`

Color of text under the cursor. Supports hex, X11 names, `cell-foreground`, `cell-background`.

### `cursor-click-to-move`

Move cursor at prompts via Alt+click (Linux) / Option+click (macOS). Requires shell integration.

### `bold-color`

Color for bold text. Can be a specific color or `bright` to use bright palette colors.

*Available since: 1.2.0*

### `faint-opacity`

Opacity of faint text (0.0 to 1.0).

*Available since: 1.2.0*

---

## Mouse & Input

### `mouse-hide-while-typing`

Hide the mouse when typing. Becomes visible again on mouse activity.

### `scroll-to-bottom`

When to scroll to bottom. Comma-separated options: `keystroke` (default: on), `output` (default: off, unimplemented).

### `mouse-shift-capture`

Whether programs can detect shift+click. Values: `true`, `false` (default), `always`, `never`.

### `mouse-scroll-multiplier`

Scroll distance multiplier for mouse wheel. Default: `3`. Range: 0.01-10000.

*Available since: 1.2.0*

---

## Opacity & Blur

### `background-opacity`

Window background opacity (0.0 to 1.0). Disabled in native fullscreen on macOS. Requires restart on macOS.

### `background-opacity-cells`

Apply `background-opacity` to cells with explicit background colors too. Default: `false`.

*Available since: 1.2.0*

### `background-blur`

Blur background when `background-opacity < 1`. Values: `true` (intensity 20), `false`, or a nonneg integer.

Supported on macOS and some Linux DEs (KDE Plasma).

### `unfocused-split-opacity`

Opacity of unfocused splits (0.15 to 1.0). Default: slightly faded.

### `unfocused-split-fill`

Color for dimming unfocused splits. Defaults to background color.

### `split-divider-color`

Color of split dividers. Hex or X11 color name.

*Available since: 1.1.0*

---

## Command & Environment

### `command`

The command to run (usually a shell). Supports `direct:` prefix (no shell expansion) and `shell:` prefix.

### `initial-command`

Same as `command`, but only applies to the first terminal surface. Supports the `-e` CLI flag.

### `env`

Extra environment variables. Format: `KEY=VALUE`. Can be repeated. Empty string resets.

*Available since: 1.2.0*

### `input`

Data to send as input on startup. Formats: `raw:<string>`, `path:<filepath>`. Can be repeated.

*Available since: 1.2.0*

### `wait-after-command`

Keep terminal open after command exits until a keypress.

### `abnormal-command-exit-runtime`

Milliseconds of runtime below which an exit is considered abnormal.

### `scrollback-limit`

Scrollback buffer size in bytes per terminal surface. Oldest lines removed when limit reached.

---

## Links

### `link`

Match regex against terminal text and associate with an action.

### `link-url`

Enable URL matching on hover with Ctrl (Linux) / Cmd (macOS). Default: enabled.

### `link-previews`

Show link previews. Values: `true`, `false`, `osc8`.

*Available since: 1.2.0*

---

## Window Options

### `maximize`

Start windows maximized. *Available since: 1.1.0*

### `fullscreen`

Start windows in fullscreen.

### `title`

Force a specific window title, ignoring escape sequences from programs.

### `class`

Application class (WM_CLASS on X11, Wayland app ID). Default: `com.mitchellh.ghostty`. GTK only.

### `x11-instance-name`

Instance name field of WM_CLASS. Default: `ghostty`. GTK only.

### `working-directory`

Starting directory. Default: `inherit` (or `home` when launched from desktop). Values: `home`, `inherit`, or an absolute path.

### `window-padding-x` / `window-padding-y`

Horizontal/vertical padding in points. Supports two comma-separated values for asymmetric padding.

### `window-padding-balance`

Auto-balance extra padding from non-divisible viewport dimensions. Default: inherent behavior.

### `window-padding-color`

Padding area color. Values: `background`, `extend`, `extend-always`.

### `window-vsync`

Sync rendering with screen refresh. Default: `true`. macOS only.

### `window-inherit-working-directory`

New windows/tabs inherit focused window's working directory.

### `window-inherit-font-size`

New windows/tabs inherit focused window's font size.

### `window-decoration`

Window decoration preference. Values: `none`, `auto` (default), `client`, `server`. Also accepts `true`/`false`.

### `window-title-font-family`

Font for window/tab titles. *Available since: 1.1.0 (GTK)*

### `window-subtitle`

Subtitle text. Values: `false`, `working-directory`. GTK only. *Available since: 1.1.0*

### `window-theme`

Window theme. Values: `auto` (default), `system`, `light`, `dark`, `ghostty` (Linux only).

### `window-colorspace`

Color space for terminal colors. Values: `srgb` (default), `display-p3`. macOS only.

### `window-height` / `window-width`

Initial window size in grid cells. Both must be set. Minimum: 10x4.

### `window-position-x` / `window-position-y`

Starting window position in pixels. macOS only.

### `window-save-state`

Save/restore window state. Values: `default`, `never`, `always`. macOS only.

### `window-step-resize`

Resize in cell-size increments. macOS only.

### `window-new-tab-position`

Where new tabs are created. Values: `current`, `end`.

### `window-show-tab-bar`

Tab bar visibility. Values: `always`, `auto` (default), `never`. GTK only.

### `window-titlebar-background` / `window-titlebar-foreground`

Titlebar colors. Only effective with `window-theme = ghostty`. GTK only.

---

## Resize Overlay

### `resize-overlay`

When to show resize overlays. Values: `always`, `never`, `after-first` (default).

### `resize-overlay-position`

Overlay position. Values: `center` (default), `top-left`, `top-center`, `top-right`, `bottom-left`, `bottom-center`, `bottom-right`.

### `resize-overlay-duration`

How long the overlay is visible. Default: `750ms`. Uses time unit syntax (e.g., `1h30m`, `45s`).

---

## Focus & Clipboard

### `focus-follows-mouse`

Mouse selects focused split pane. Default: `false`.

### `clipboard-read` / `clipboard-write`

Allow programs to read/write clipboard (OSC 52). Values: `ask`, `allow`, `deny`.

### `clipboard-trim-trailing-spaces`

Trim trailing whitespace on clipboard copy.

### `clipboard-paste-protection`

Confirm before pasting unsafe text (text with newlines).

### `clipboard-paste-bracketed-safe`

Treat bracketed pastes as safe. Default: `true`.

### `title-report`

Enable title reporting (CSI 21 t). Default: disabled.

> **Warning:** Can expose sensitive information or enable arbitrary code execution.

### `image-storage-limit`

Max bytes for image data per terminal screen. Default: 320MB. Max: 4GiB. Set to 0 to disable image protocols.

### `copy-on-select`

Auto-copy selected text. Values: `true` (default on Linux/macOS), `false`, `clipboard`.

### `right-click-action`

Right-click behavior. Values: `context-menu` (default), `paste`, `copy`, `copy-or-paste`, `ignore`.

### `click-repeat-interval`

Milliseconds between clicks for repeat detection. Default: platform-specific (500ms on non-macOS).

---

## Config Files

### `config-file`

Additional config files to read. Supports `?` prefix for optional files. Cycles are not allowed.

### `config-default-files`

Load default config file paths. CLI-only configuration.

---

## Application Behavior

### `confirm-close-surface`

Confirm before closing surfaces. Values: `true` (default), `false`, `always`.

### `quit-after-last-window-closed`

Quit when last window closes. Default: `false` on macOS, `true` on Linux.

### `quit-after-last-window-closed-delay`

Delay before quitting after last window closes. Minimum: `1s`. Linux only.

### `initial-window`

Create an initial window on launch. Linux and macOS only.

### `undo-timeout`

Duration undo operations remain available. Default: `5s`. macOS only.

*Available since: 1.2.0*

---

## Quick Terminal

### `quick-terminal-position`

Position. Values: `top`, `bottom`, `left`, `right`, `center`.

### `quick-terminal-size`

Size as percentage (`20%`) or pixels (`300px`). Two comma-separated values for both axes.

*Available since: 1.2.0*

### `gtk-quick-terminal-layer`

Wayland layer. Values: `overlay`, `top` (default), `bottom`, `background`. GTK Wayland only.

*Available since: 1.2.0*

### `gtk-quick-terminal-namespace`

Wayland namespace identifier. GTK Wayland only.

*Available since: 1.2.0*

### `quick-terminal-screen`

Which screen for quick terminal. Values: `main` (default), `mouse`, `macos-menu-bar`. macOS only.

### `quick-terminal-animation-duration`

Animation duration in seconds. Set to `0` to disable. macOS only.

### `quick-terminal-autohide`

Auto-hide on focus loss. Default: `true` on macOS, `false` on Linux.

### `quick-terminal-space-behavior`

Behavior when switching macOS spaces. Values: `move` (default), `remain`. macOS only.

*Available since: 1.1.0*

### `quick-terminal-keyboard-interactivity`

Keyboard input behavior. Values: `none`, `on-demand` (default), `exclusive`. Wayland only.

*Available since: 1.2.0*

---

## Shell Integration

### `shell-integration`

Auto-injection mode. Values: `none`, `detect` (default), `bash`, `elvish`, `fish`, `zsh`.

### `shell-integration-features`

Features to enable. Comma-separated, prefix with `no-` to disable.

Available features:
- `cursor` -- Blinking bar cursor at prompt.
- `sudo` -- Preserve terminfo with sudo.
- `title` -- Set window title via shell integration.
- `ssh-env` -- SSH environment variable compatibility. *(Available since: 1.2.0)*
- `ssh-terminfo` -- Auto-install terminfo on remote hosts. *(Available since: 1.2.0)*

### `command-palette-entry`

Custom command palette entries. Format: `title:Name, action:action_name`.

*Available since: 1.2.0*

---

## Keybindings

### `keybind`

Key bindings. Format: `trigger=action`.

**Trigger format:** `modifier+key` (e.g., `ctrl+a`, `ctrl+shift+b`). Supports Unicode codepoints and [W3C physical key codes](https://www.w3.org/TR/uievents-code/).

**Modifiers:** `shift`, `ctrl` (`control`), `alt` (`opt`, `option`), `super` (`cmd`, `command`).

**Sequences:** Use `>` for key chords (e.g., `ctrl+a>n=new_window`).

**Special values:**
- `keybind=clear` -- Clear all keybindings.

**Prefixes:**
- `all:` -- Apply to all terminal surfaces.
- `global:` -- Make keybind work system-wide (macOS, some Linux).
- `unconsumed:` -- Don't consume the input; forward to terminal.
- `performable:` -- Only consume if action can be performed.

---

## Miscellaneous

### `osc-color-report-format`

OSC color query format. Values: `none`, `8-bit`, `16-bit` (default).

### `vt-kam-allowed`

Allow KAM mode (ANSI mode 2). Default: `false`.

### `custom-shader`

Path to a GLSL custom shader file. Shadertoy-compatible. Can be repeated for multiple shaders.

> **Warning:** Invalid shaders can make Ghostty unusable (e.g., completely black window).

### `custom-shader-animation`

Animation loop for custom shaders. Values: `true` (default), `false`, `always`.

### `bell-features`

Bell features. Comma-separated: `system`, `audio`, `attention` (default: on), `title` (default: on), `border`.

*Available since: 1.2.0*

### `bell-audio-path`

Path to audio file for bell. GTK only. *Available since: 1.2.0*

### `bell-audio-volume`

Bell audio volume (0.0 to 1.0). Default: `0.5`. GTK only. *Available since: 1.2.0*

### `app-notifications`

Control in-app notifications. Options: `clipboard-copy`, `config-reload`. Prefix with `no-` to disable. GTK only.

*Available since: 1.1.0*

### `desktop-notifications`

Allow programs to show desktop notifications (OSC 9, OSC 777). Default: `true`.

### `term`

Sets the `TERM` environment variable.

### `enquiry-response`

String to send on ENQ (`0x05`). Default: empty.

### `async-backend`

Low-level async IO backend. Values: `auto` (default), `epoll`, `io_uring`. Linux only.

*Available since: 1.2.0*

---

## macOS-Specific

### `macos-non-native-fullscreen`

Non-native fullscreen mode. Values: `true`, `false` (default), `visible-menu`, `padded-notch`.

> **Important:** Tabs do NOT work in non-native fullscreen mode.

### `macos-window-buttons`

Traffic light visibility. Values: `visible` (default), `hidden`.

*Available since: 1.2.0*

### `macos-titlebar-style`

Titlebar style. Values: `native`, `transparent` (default), `tabs`, `hidden`.

### `macos-titlebar-proxy-icon`

Proxy icon visibility. Values: `visible` (default), `hidden`.

### `macos-dock-drop-behavior`

Dock drop behavior. Values: `new-tab` (default), `new-window`.

### `macos-option-as-alt`

Treat Option as Alt. Values: `true`, `false`, `left`, `right`. Default depends on keyboard layout.

### `macos-window-shadow`

Window shadow. Default: `true`.

### `macos-hidden`

Hide from dock/app switcher. Values: `never` (default), `always`.

*Available since: 1.2.0*

### `macos-auto-secure-input`

Auto-enable secure input at password prompts.

### `macos-secure-input-indication`

Show graphical indication when secure input is enabled.

### `macos-icon`

Customize app icon. Values: `official`, `blueprint`, `chalkboard`, `microchip`, `glass`, `holographic`, `paper`, `retro`, `xray`, `custom`, `custom-style`.

### `macos-custom-icon`

Path to custom icon file (PNG, JPEG, ICNS). Default: `~/.config/ghostty/Ghostty.icns`.

### `macos-icon-frame`

Icon frame material. Values: `aluminum` (default), `beige`, `plastic`, `chrome`.

### `macos-icon-ghost-color`

Ghost color in app icon. Required for `custom-style`.

### `macos-icon-screen-color`

Screen gradient color(s) in app icon. Up to 64 comma-separated colors. Required for `custom-style`.

### `macos-shortcuts`

Allow macOS Shortcuts to control Ghostty. Values: `ask`, `allow`, `deny`.

*Available since: 1.2.0*

---

## Auto-Update (macOS)

### `auto-update`

Auto-update behavior. Values: `off`, `check`, `download`.

### `auto-update-channel`

Release channel. Values: `stable`, `tip`.

---

## Linux-Specific

### `linux-cgroup`

Cgroup isolation per surface. Values: `never`, `always`, `single-instance` (default).

### `linux-cgroup-memory-limit`

Memory limit per terminal process (bytes). Sets `memory.high` (soft limit).

### `linux-cgroup-processes-limit`

Process count limit per terminal. Sets `pids.max` (hard limit).

### `linux-cgroup-hard-fail`

Fail on cgroup init errors. Default: `false`.

---

## GTK-Specific

### `gtk-opengl-debug`

OpenGL debug logs. Default: `false` (except debug builds). *Available since: 1.1.0*

### `gtk-single-instance`

Single-instance mode. Values: `true`, `false`, `detect` (default).

### `gtk-titlebar`

Show full GTK titlebar. No effect when `window-decoration` is `false`.

### `gtk-tabs-location`

Tab bar position. Values: `top` (default), `bottom`, `hidden`.

### `gtk-titlebar-hide-when-maximized`

Hide titlebar when maximized. *Available since: 1.1.0*

### `gtk-toolbar-style`

Top/bottom bar appearance. Values: `flat`, `raised`, `raised-border`.

### `gtk-titlebar-style`

GTK titlebar style. Values: `native` (default), `tabs`.

### `gtk-wide-tabs`

Wide tabs (Gnome-style). Default: `true`.

### `gtk-custom-css`

Custom CSS files. Can be repeated. Supports `?` prefix for optional files. Max: 5MiB per file.

*Available since: 1.1.0*
