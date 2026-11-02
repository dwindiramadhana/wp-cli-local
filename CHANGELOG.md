# Changelog

## 1.1.0

### Fixed
- Site names containing quotes (e.g. `Bri'cks`) crashed the wrapper with a Python SyntaxError. Names are now passed to Python as arguments.
- `-s <name>` fuzzy matching treated `[`, `*` and `?` in names as glob characters. It is now a plain case-insensitive substring match.
- PHP and MySQL folder lookup matched by prefix (`8.2.2` could match `8.2.27+1`). It now anchors on the `+<build>` suffix Local uses.
- When Local's `lightning-services` folder was missing, the wrapper exited silently. It now shows the "Could not find PHP/MySQL" message.
- `setup-direnv` used the same unsafe name handling and version lookup. Its generated-file counter also reset inside a pipeline, so the summary always showed 0.

- `setup-direnv <unknown-site>` printed an error but still exited 0 and printed "Done". It now exits 1.
- The database folder is looked up by the service name Local recorded, and missing PHP or database binaries produce a clear error instead of a raw exec failure.

### Added
- `tests/test.sh`: 21 checks against a fake Local layout (quoted names, glob characters, version anchoring, missing folders, direnv generation).
- `install.sh`: checks macOS, python3, WP-CLI, and Local; installs to `~/.claude/skills/wp-cli-local`; links `~/bin/local-wp`. Does not overwrite an existing install.
- `CHANGELOG.md`.

## 1.0.0

- Initial release: WP-CLI wrapper for Local by Flywheel with CWD auto-detection, `-s` fuzzy matching, `--list`, site status warnings, and optional direnv setup.
