#!/usr/bin/env bash
#
# Rebrand the Android app: package name (applicationId + namespace) and
# optional display name (AndroidManifest label).
#
# Usage:
#   tools/rebrand.sh --package <reverse.dns.id> [--name "<Display Name>"] [--yes]
#
# Lock semantics:
#   android/play_status.yaml `published:` gates rebrands.
#     - false: script prompts "Has the app been published to Play yet? (y/N)"
#         N -> rebrand proceeds, last_checked is bumped.
#         y -> sets published: true, aborts rebrand (now locked).
#     - true:  rebrand is refused. Edit play_status.yaml manually to override.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GRADLE="$ROOT/android/app/build.gradle.kts"
MANIFEST="$ROOT/android/app/src/main/AndroidManifest.xml"
KOTLIN_ROOT="$ROOT/android/app/src/main/kotlin"
STATUS_FILE="$ROOT/android/play_status.yaml"

NEW_PACKAGE=""
NEW_NAME=""
ASSUME_YES=0

usage() {
    cat <<EOF
Usage: $0 --package <reverse.dns.id> [--name "<Display Name>"] [--yes]

Example:
  $0 --package dev.ludraga.cato --name "Cato"
EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --package) NEW_PACKAGE="${2:-}"; shift 2 ;;
        --name)    NEW_NAME="${2:-}";    shift 2 ;;
        --yes)     ASSUME_YES=1; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown arg: $1"; usage ;;
    esac
done

[[ -z "$NEW_PACKAGE" ]] && usage

# 1. Validate reverse-DNS package format.
if ! [[ "$NEW_PACKAGE" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
    echo "ERROR: '$NEW_PACKAGE' is not a valid reverse-DNS package (e.g. dev.ludraga.cato)."
    exit 1
fi

# 2. Dirty working tree check.
if [[ -n "$(git -C "$ROOT" status --porcelain)" ]]; then
    echo "ERROR: working tree is dirty. Commit or stash before rebranding."
    exit 1
fi

# 3. Read current package.
CURRENT_PACKAGE="$(grep -E '^\s*applicationId\s*=' "$GRADLE" | sed -E 's/.*"([^"]+)".*/\1/')"
if [[ -z "$CURRENT_PACKAGE" ]]; then
    echo "ERROR: could not read applicationId from $GRADLE"
    exit 1
fi

if [[ "$CURRENT_PACKAGE" == "$NEW_PACKAGE" ]]; then
    echo "Package already $NEW_PACKAGE — nothing to rename."
    if [[ -n "$NEW_NAME" ]]; then
        echo "Updating display name only."
    else
        exit 0
    fi
fi

# 4. Play-status gate.
if [[ ! -f "$STATUS_FILE" ]]; then
    echo "ERROR: $STATUS_FILE missing."
    exit 1
fi
PUBLISHED="$(grep -E '^\s*published\s*:' "$STATUS_FILE" | awk '{print $2}')"

if [[ "$PUBLISHED" == "true" ]]; then
    echo "ERROR: play_status.yaml says published: true. Package name is locked."
    echo "Edit android/play_status.yaml manually if you know what you're doing."
    exit 1
fi

if [[ "$ASSUME_YES" -ne 1 ]]; then
    echo "Current package: $CURRENT_PACKAGE"
    echo "New package:     $NEW_PACKAGE"
    [[ -n "$NEW_NAME" ]] && echo "New display name: $NEW_NAME"
    echo
    read -r -p "Has Cato been published to the Play Store yet? (y/N) " published_answer
    case "$published_answer" in
        [yY]|[yY][eE][sS])
            sed -i.bak -E 's/^(\s*published\s*:\s*).*/\1true/' "$STATUS_FILE"
            sed -i.bak -E "s/^(\s*last_checked\s*:\s*).*/\1$(date +%Y-%m-%d)/" "$STATUS_FILE"
            rm -f "$STATUS_FILE.bak"
            echo "Recorded published: true in $STATUS_FILE. Rebrand aborted (package now locked)."
            exit 0
            ;;
    esac
    read -r -p "Proceed with rebrand? (y/N) " confirm
    [[ "$confirm" =~ ^[yY] ]] || { echo "Aborted."; exit 1; }
fi

# 5. Bump last_checked.
sed -i.bak -E "s/^(\s*last_checked\s*:\s*).*/\1$(date +%Y-%m-%d)/" "$STATUS_FILE"
rm -f "$STATUS_FILE.bak"

# 6. Rewrite build.gradle.kts.
sed -i.bak -E "s|^(\s*namespace\s*=\s*\")[^\"]+(\")|\1$NEW_PACKAGE\2|" "$GRADLE"
sed -i.bak -E "s|^(\s*applicationId\s*=\s*\")[^\"]+(\")|\1$NEW_PACKAGE\2|" "$GRADLE"
rm -f "$GRADLE.bak"

# 7. Move kotlin source folder if the old path exists.
OLD_PATH="$KOTLIN_ROOT/$(echo "$CURRENT_PACKAGE" | tr . /)"
NEW_PATH="$KOTLIN_ROOT/$(echo "$NEW_PACKAGE" | tr . /)"
if [[ -d "$OLD_PATH" ]] && [[ "$OLD_PATH" != "$NEW_PATH" ]]; then
    mkdir -p "$NEW_PATH"
    # git mv each .kt to preserve history
    while IFS= read -r -d '' kt; do
        rel="$(basename "$kt")"
        git -C "$ROOT" mv "$kt" "$NEW_PATH/$rel"
    done < <(find "$OLD_PATH" -maxdepth 1 -name '*.kt' -print0)
    # Prune empty old dirs walking upward.
    dir="$OLD_PATH"
    while [[ -d "$dir" && -z "$(ls -A "$dir")" && "$dir" != "$KOTLIN_ROOT" ]]; do
        rmdir "$dir"
        dir="$(dirname "$dir")"
    done
fi

# 8. Rewrite `package` declaration in each .kt under the new path.
if [[ -d "$NEW_PATH" ]]; then
    while IFS= read -r -d '' kt; do
        sed -i.bak -E "s|^package\s+[A-Za-z0-9_.]+|package $NEW_PACKAGE|" "$kt"
        rm -f "$kt.bak"
    done < <(find "$NEW_PATH" -maxdepth 1 -name '*.kt' -print0)
fi

# 9. Optional display name update.
if [[ -n "$NEW_NAME" ]]; then
    sed -i.bak -E "s|android:label=\"[^\"]+\"|android:label=\"$NEW_NAME\"|" "$MANIFEST"
    rm -f "$MANIFEST.bak"
fi

# 10. Flag any stray references to the old package across the repo
#     (excluding build artefacts and the git history).
echo
echo "Stray references to '$CURRENT_PACKAGE' (review and update if needed):"
git -C "$ROOT" grep -n -F "$CURRENT_PACKAGE" -- ':!build' ':!**/build' ':!docs' || echo "  none"

# 11. Clean Flutter caches so stale R-classes don't bite.
(cd "$ROOT" && flutter clean >/dev/null)

echo
echo "Rebrand complete:"
echo "  package: $CURRENT_PACKAGE -> $NEW_PACKAGE"
[[ -n "$NEW_NAME" ]] && echo "  display name: $NEW_NAME"
echo
echo "Next: run 'flutter pub get' then 'flutter run' to verify."
