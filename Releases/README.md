# Release Notes

Store one lightweight Markdown file here for every build you send to TestFlight or beyond.

Naming convention:

- `<marketing-version>-build-<build-number>.md`

Examples:

- `1.0-build-2.md`
- `1.0.1-build-7.md`

Each file should capture:

- Build date
- Build intent
- What changed
- Known issues
- Tester focus

Use `scripts/create_release_notes.sh` to generate the next file from the Xcode project version settings.
