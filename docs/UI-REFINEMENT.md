# Native interface refinement

This is an Operate surface: a frequently used macOS clock and time-zone tool.
Preserve the cyan identity, SF system type, SF Symbols, familiar controls, all
preferences, keyboard navigation, and macOS 13 support.

The taste direction is restrained: DESIGN_VARIANCE 5, MOTION_INTENSITY 3,
VISUAL_DENSITY 4. Marketing page rules, decorative photography, web frameworks,
and scroll effects do not apply to these native utility windows.

| Before | After | Reason |
| --- | --- | --- |
| Dense clock actions and two dividers | One divider, consistent 36-point rows, quieter Quit action | Keep the time dominant and actions easy to scan |
| One long settings form | General, Appearance, and About panes with native segmented navigation | Keep related settings visible together |
| Narrow preview strip | Persistent 44-point preview using the real menu-bar renderer | Make appearance edits easy to judge |
| Right-aligned labels beside cramped converter fields | Labels above full-width native fields | Improve reading order and localization space |
| Copy has no visible result | Immediate checkmark with a stable button size | Confirm success without changing layout |
| Empty or invalid values can appear copyable | Copy availability follows valid conversion state | Avoid copying stale results |

Motion follows the Emil Design Engineering frequency rule. Hover changes only
the row background, pointer presentation takes 140 ms, and keyboard dismissal
is immediate. Reduced Motion disables presentation movement; Reduced
Transparency uses an opaque native surface. No clock-tick animation.

`InterfaceStyle` owns the common accent and window sizes. SwiftUI and AppKit
continue to own native focus, text editing, selection, menus, and controls.

Render the actual views with `scripts/render-readme.sh <output-directory>`.
The matrix includes English and Chinese, light and dark, all settings panes,
seconds, and empty/invalid conversion states.
