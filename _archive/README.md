# Archive

Frozen artifacts kept for reference. **Do not edit.** Make changes in the SPM project at the repo root.

## `UTCMenuBar-xcode/`

The original Xcode project. It inlines `DisplayOptions`, `TimeFormatter`, `MenuBuilder` directly into `AppDelegate.swift` — a copy of the code that now lives in `Sources/UTCMenuBarLib/`. Was kept around in case someone needed an Xcode project to open, but the SPM build with `scripts/build-app.sh` produces the same `.app` and is the only path that's maintained.

If the Xcode project is no longer useful, this whole directory is safe to delete.
