# wp-cli-local

A Claude Code skill that wraps WP-CLI to work seamlessly with [Local by Flywheel](https://localwp.com/) sites on macOS.

Auto-detects the target site from your working directory, resolves the correct PHP/MySQL binaries from Local's lightning-services, and forwards commands through WP-CLI. Supports fuzzy site name matching, site status checks, and optional direnv setup for interactive terminal use.

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

## Install as a Claude Code skill

Clone this repo directly into your Claude Code skills directory:

```bash
git clone https://github.com/dwindown/wp-cli-local.git ~/.claude/skills/wp-cli-local
```

That's it. Claude Code auto-discovers skills from `~/.claude/skills/`. The skill will trigger when you ask Claude to run WP-CLI commands (e.g. "activate plugin", "flush cache", "wp option", "wp db").

## Usage in Claude Code

Once installed, just ask Claude naturally:

```
"list plugins on my site"
"flush the cache"
"run wp db query to find all draft posts"
"what's the siteurl option?"
```

Claude will use the wrapper script automatically. No manual invocation needed.

## Usage from the terminal (optional)

If you also want bare `wp` commands in your own terminal:

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

## License

MIT
