#!/bin/bash
# Tests for scripts/wp and scripts/setup-direnv.
#
# Builds a fake Local layout in a temp HOME, so it needs no Local install,
# no running site, and no real WP-CLI. Run: bash tests/test.sh

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WP="$ROOT/scripts/wp"
DIRENV="$ROOT/scripts/setup-direnv"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

if [[ "$(uname -m)" == "arm64" ]]; then ARCH_DIR="darwin-arm64"; else ARCH_DIR="darwin"; fi

HOME_DIR="$TMP/home"
LOCAL="$HOME_DIR/Library/Application Support/Local"
BIN="$TMP/bin"
mkdir -p "$LOCAL" "$BIN"

# Fake PHP (prints what it was called with) and a fake wp-cli file.
mkdir -p "$LOCAL/lightning-services/php-8.2.27+1/bin/$ARCH_DIR/bin"
printf '#!/bin/bash\necho "PHP-CALLED: $*"\n' > "$LOCAL/lightning-services/php-8.2.27+1/bin/$ARCH_DIR/bin/php"
chmod +x "$LOCAL/lightning-services/php-8.2.27+1/bin/$ARCH_DIR/bin/php"
mkdir -p "$LOCAL/lightning-services/mysql-8.0.35+4/bin/$ARCH_DIR/bin"
printf '#!/bin/bash\n' > "$BIN/wp"
chmod +x "$BIN/wp"

site() { # id name php mysql
  cat <<EOF
"$1":{"id":"$1","name":"$2","path":"$HOME_DIR/sites/$1","services":{"php":{"version":"$3"},"mysql":{"name":"mysql","version":"$4"}}}
EOF
}

{
  echo "{"
  site A1 "Alpha" 8.2.27 8.0.35; echo ","
  site A2 "Alphabet" 8.2.27 8.0.35; echo ","
  site Q1 "O'Brien" 8.2.27 8.0.35; echo ","
  site G1 "Glob[1]" 8.2.27 8.0.35; echo ","
  site P1 "Prefix" 8.2.2 8.0.35
  echo "}"
} > "$LOCAL/sites.json"
echo '{"A1":"running","Q1":"halted"}' > "$LOCAL/site-statuses.json"
for id in A1 A2 Q1 G1 P1; do
  mkdir -p "$LOCAL/run/$id/conf/php" "$HOME_DIR/sites/$id/app/public"
  : > "$LOCAL/run/$id/conf/php/php.ini"
done

PASS=0
FAIL=0

# check <description> <expected substring> <exit code expected> <command...>
check() {
  local desc="$1" want="$2" want_rc="$3"
  shift 3
  local out rc
  out="$(HOME="$HOME_DIR" PATH="$BIN:$PATH" "$@" 2>&1)"
  rc=$?
  if [[ "$out" == *"$want"* && "$rc" -eq "$want_rc" ]]; then
    PASS=$((PASS + 1))
    echo "  ok    $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL  $desc (exit $rc, wanted $want_rc, wanted output containing: $want)"
    echo "$out" | sed 's/^/        /'
  fi
}

echo "wp"
check "--list shows sites"                    "Alphabet"                         0 bash "$WP" --list
check "exact name wins over longer match"     "[Alpha] wp core version"          0 bash "$WP" -s Alpha core version
check "substring match is case-insensitive"   "[O'Brien] wp core version"        0 bash "$WP" -s "o'BR" core version
check "ambiguous substring lists candidates"  "Ambiguous match"                  1 bash "$WP" -s alph core version
check "name with a quote resolves"            "[O'Brien] wp core version"        0 bash "$WP" -s "O'Brien" core version
check "quote in unknown name fails cleanly"   "not found in Local"               1 bash "$WP" -s "Bri'cks" core version
check "bracket is literal, not a glob"        "[Glob[1]] wp core version"        0 bash "$WP" -s "[1]" core version
check "star is literal, not a glob"           "not found in Local"               1 bash "$WP" -s "A*" core version
check "--site=NAME form works"                "[Alpha] wp core version"          0 bash "$WP" --site=Alpha core version
check "forwards args to PHP with site path"   "--path=$HOME_DIR/sites/A1/app/public" 0 bash "$WP" -s Alpha plugin list
check "stopped site shows a warning"          "is halted"                        0 bash "$WP" -s "O'Brien" core version
check "8.2.2 does not match php 8.2.27+1"    "Could not find PHP 8.2.2"         1 bash "$WP" -s Prefix core version
check "auto-detect from site subfolder"       "[Alpha] wp core version"          0 bash -c "cd '$HOME_DIR/sites/A1/app/public' && bash '$WP' core version"
check "outside a site gives a clear error"    "Could not auto-detect"            1 bash -c "cd '$TMP' && bash '$WP' core version"

mv "$LOCAL/lightning-services" "$LOCAL/lightning-services.off"
check "missing lightning-services is reported" "Could not find PHP"              1 bash "$WP" -s Alpha core version
mv "$LOCAL/lightning-services.off" "$LOCAL/lightning-services"

mv "$LOCAL/sites.json" "$LOCAL/sites.json.off"
check "missing sites.json is reported"        "sites file not found"             1 bash "$WP" --list
mv "$LOCAL/sites.json.off" "$LOCAL/sites.json"

echo "setup-direnv"
check "--list shows sites"                    "Alpha"                            0 bash "$DIRENV" --list
check "unknown site fails cleanly"            "not found"                        1 bash "$DIRENV" "Bri'cks"
check "generates .envrc and counts it"        "Generated: 1 | Skipped: 0"        0 bash "$DIRENV" Alpha
[[ -f "$HOME_DIR/sites/A1/.envrc" ]] && { PASS=$((PASS + 1)); echo "  ok    .envrc written"; } \
  || { FAIL=$((FAIL + 1)); echo "  FAIL  .envrc not written"; }
check "skips sites with a missing PHP"        "Skipping Prefix"                  0 bash "$DIRENV" Prefix

echo ""
echo "Passed: $PASS | Failed: $FAIL"
[[ "$FAIL" -eq 0 ]]
