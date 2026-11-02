# wp-cli-local

A WP-CLI wrapper for [Local by Flywheel](https://localwp.com/) sites on macOS. Works with **Claude Code**, **Codex**, **Cursor**, or any AI coding agent — plus your own terminal.

Auto-detects the target site from your working directory, resolves the correct PHP/MySQL binaries from Local's lightning-services, and forwards commands through WP-CLI. Supports fuzzy site name matching, site status checks, and optional direnv setup.

## Features

- **Auto-detection** — matches your CWD against Local's `sites.json` to find the right site
- **Fuzzy matching** — use `-s mysite` to target a site by partial name
- **Site status check** — warns you if the target site isn't running
- **Architecture-aware** — works on both Apple Silicon and Intel Macs
- **direnv setup** — optional `setup-direnv` script for bare `wp` commands in your terminal

## Requirements

- macOS (Apple Silicon or Intel)
- [Local by Flywheel](https://localwp.com/) installed with sites
- [WP-CLI](https://wp-cli.org/) installed (`brew install wp-cli`)
- Python 3 (pre-installed on macOS)

## Install

### Option A — Installer (recommended)

Unzip the package, open Terminal in the unzipped folder, and run:

```bash
bash install.sh
```

The installer checks your requirements, copies the skill to `~/.claude/skills/wp-cli-local`, and links the wrapper as `~/bin/local-wp`. It does not use sudo. If `~/bin` is not on your PATH, it prints the one line to add to your shell config.

If `~/.claude/skills/wp-cli-local` already exists, the installer keeps that copy. To update, replace the folder with the new package.

### Option B — Git clone

```bash
git clone https://github.com/dwindiramadhana/wp-cli-local.git ~/.claude/skills/wp-cli-local
chmod +x ~/.claude/skills/wp-cli-local/scripts/wp
mkdir -p ~/bin && ln -sfn ~/.claude/skills/wp-cli-local/scripts/wp ~/bin/local-wp
```

### Make `local-wp` available everywhere (optional)

Once the symlink exists, any tool can run `local-wp plugin list` like a normal CLI command.

### Add AGENTS.md to your project (optional)

Copy the included `AGENTS.md` into your project root so any AI coding agent (Codex, Cursor, etc.) knows to use the wrapper:

```bash
cp ~/.claude/skills/wp-cli-local/AGENTS.md /path/to/your/project/AGENTS.md
```

## Usage with different tools

### Claude Code

No extra setup needed. Claude Code auto-discovers skills from `~/.claude/skills/`. Just ask naturally:

```
"list plugins on my site"
"flush the cache"
"run wp db query to find all draft posts"
```

### Codex / Cursor / other AI agents

The included `AGENTS.md` tells the agent to use the wrapper. Drop it in your project root. If you symlinked `local-wp` into PATH, the agent can also call it directly:

```
local-wp plugin list
local-wp -s my-site cache flush
```

### Your own terminal

```bash
local-wp plugin list          # if symlinked
# or
bash ~/.claude/skills/wp-cli-local/scripts/wp plugin list
```

## Usage in Claude Code

Once installed, just ask Claude naturally:

```
"list plugins on my site"
"flush the cache"
"run wp db query to find all draft posts"
"what's the siteurl option?"
```

Claude will use the wrapper script automatically. No manual invocation needed.

## direnv setup (optional)

If you want bare `wp` commands in your terminal without the wrapper:

```bash
# Generate .envrc files for all Local sites
bash ~/.claude/skills/wp-cli-local/scripts/setup-direnv

# Then cd into a site directory and allow direnv
cd ~/Local\ Sites/my-site
direnv allow

# Now you can use wp directly
wp --path=./app/public plugin list
```

Requires [direnv](https://direnv.net/) (`brew install direnv`).

## Wrapper script usage

```bash
WP="bash ~/.claude/skills/wp-cli-local/scripts/wp"

# Auto-detect (run from inside a Local site directory)
$WP plugin list

# Explicit site
$WP -s my-site plugin list

# Fuzzy match
$WP -s my plugin list

# List all sites
$WP --list
```

## Limitations

- macOS only. The wrapper reads Local's own files (`sites.json`, `lightning-services`, `run/<site-id>/conf`). These are not a documented API, so a future Local update could change them.
- Tested with MySQL-based Local sites. MariaDB sites have not been tested; if the database binaries are missing the wrapper says so instead of failing silently.
- The target site should be running in Local, because its `php.ini` only exists while it runs.

## Tests

The test suite builds a fake Local layout in a temporary folder, so it needs no Local install and does not touch your real sites:

```bash
bash tests/test.sh
```

## License

MIT
