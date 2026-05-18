## WP-CLI for Local by Flywheel

When running WP-CLI commands against a Local by Flywheel site, always use the wrapper script — never run bare `wp` commands.

```bash
bash ~/.claude/skills/wp-cli-local/scripts/wp <wp-cli-command...>
```

### How it works

- The wrapper auto-detects the site from the current working directory by matching against Local's `sites.json`.
- If auto-detection fails, use `-s <name>` or `--site=<name>` to target a site. Supports fuzzy/partial matching.
- Use `--list` to show all sites with running/halted status.
- The target site **must be running** in Local.

### Examples

```bash
WP="bash ~/.claude/skills/wp-cli-local/scripts/wp"

$WP plugin list
$WP -s my-site plugin list
$WP cache flush
$WP option get siteurl
$WP db query "SELECT * FROM wp_options LIMIT 5;"
$WP --list
```

### Requirements

- macOS (Apple Silicon or Intel)
- Local by Flywheel installed with sites in `~/Library/Application Support/Local/sites.json`
- WP-CLI installed (`brew install wp-cli`)
- Python 3

If the wrapper script is not found at `~/.claude/skills/wp-cli-local/scripts/wp`, check if it's symlinked elsewhere (e.g. `local-wp` in PATH) or install it:

```bash
git clone https://github.com/dwindiramadhana/wp-cli-local.git ~/.claude/skills/wp-cli-local
```
