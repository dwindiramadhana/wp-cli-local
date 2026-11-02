#!/bin/bash
# Installer for wp-cli-local
#
# Run from the unzipped package folder:
#   bash install.sh
#
# What it does (no sudo, nothing outside your home folder):
#   1. Checks macOS, python3, WP-CLI, and Local by Flywheel
#   2. Copies this package to ~/.claude/skills/wp-cli-local
#   3. Links the wrapper as ~/bin/local-wp
#   4. Runs `local-wp --list` as a smoke test

set -euo pipefail

INSTALL_DIR="$HOME/.claude/skills/wp-cli-local"
BIN_DIR="$HOME/bin"
LINK_PATH="$BIN_DIR/local-wp"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ok()   { echo "  ✓  $*"; }
warn() { echo "  ⚠  $*"; }
fail() { echo "  ✗  $*" >&2; exit 1; }

echo "Checking requirements..."

[[ "$(uname -s)" == "Darwin" ]] || fail "wp-cli-local only supports macOS."
ok "macOS"

command -v python3 >/dev/null 2>&1 || fail "python3 not found. Install Xcode Command Line Tools: xcode-select --install"
ok "python3"

if command -v wp >/dev/null 2>&1; then
  ok "WP-CLI ($(wp --version 2>/dev/null || echo unknown))"
else
  fail "WP-CLI not found. Install it with: brew install wp-cli"
fi

LOCAL_SITES="$HOME/Library/Application Support/Local/sites.json"
if [[ -f "$LOCAL_SITES" ]]; then
  ok "Local by Flywheel sites found"
else
  warn "Local by Flywheel not found at $LOCAL_SITES. Install Local and create a site first; the wrapper will not work until then."
fi

echo ""
echo "Installing..."

if [[ "$SOURCE_DIR" == "$INSTALL_DIR" ]]; then
  ok "Already running from $INSTALL_DIR"
elif [[ -e "$INSTALL_DIR" ]]; then
  # Never overwrite an existing install; the user may have local changes.
  warn "$INSTALL_DIR already exists. Keeping the existing copy. To update, replace that folder with this package."
else
  mkdir -p "$(dirname "$INSTALL_DIR")"
  cp -R "$SOURCE_DIR" "$INSTALL_DIR"
  ok "Copied package to $INSTALL_DIR"
fi

chmod +x "$INSTALL_DIR/scripts/wp" "$INSTALL_DIR/scripts/setup-direnv"

mkdir -p "$BIN_DIR"
if [[ -e "$LINK_PATH" && ! -L "$LINK_PATH" ]]; then
  fail "$LINK_PATH exists and is not a symlink. Remove it, then run again."
fi
ln -sfn "$INSTALL_DIR/scripts/wp" "$LINK_PATH"
ok "Linked $LINK_PATH"

echo ""
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  warn "$BIN_DIR is not on your PATH. Add this line to ~/.zshrc (or ~/.bash_profile), then open a new terminal:"
  echo ""
  echo '    export PATH="$HOME/bin:$PATH"'
  echo ""
fi

echo "Smoke test:"
if [[ -f "$LOCAL_SITES" ]]; then
  "$LINK_PATH" --list || warn "local-wp --list failed. Check the messages above."
else
  warn "Skipped: no Local sites.json yet."
fi

echo ""
echo "Done. Try: local-wp --list"
