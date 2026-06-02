<!--
Thanks for contributing to UTCMenuBar! Keep this PR focused and concise.
Fill in the sections below and delete anything that doesn't apply.
-->

## Summary

<!-- What does this PR do, and why? 1-3 sentences. Link any related issue or spec. -->



## Type of change

<!-- Check all that apply. -->

- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (changes existing behavior or public API)
- [ ] Refactor / internal cleanup (no user-facing behavior change)
- [ ] Docs only (README / CLAUDE.md / specs)
- [ ] Build / tooling (scripts, CI, packaging)

## Testing

Run the test suite and record the result:

```bash
./scripts/test.sh
```

- Pass count: <!-- e.g. 142 passed, 0 failed --> ____
- [ ] All tests pass locally
- [ ] Manually verified the change in the running app (`swift run UTCMenuBar` or `./scripts/build-app.sh && open UTCMenuBar.app`)

<!-- Briefly describe what you tested manually, if anything. -->



## Checklist

- [ ] Tests added or updated for new/changed logic (custom runner under `Tests/UTCMenuBarTests/`, registered in `TestRunner.main()`)
- [ ] No new external dependencies added to `Package.swift` (AppKit + Foundation + a little SwiftUI/Combine only)
- [ ] User-facing strings are added to the Strings table in **both** English (`en`) and Chinese (`zh`)
- [ ] `swift build` is warning-free
- [ ] `CLAUDE.md` and/or `README.md` updated if architecture or behavior changed (and `specs/` if applicable)
