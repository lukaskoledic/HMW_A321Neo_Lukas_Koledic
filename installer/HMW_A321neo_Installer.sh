#!/bin/bash
#
# HMW A321neo Installer
#
# Installs (or updates) the HoldMyWire A321neo aircraft for X-Plane 12.
# The aircraft payload is always fetched fresh from the GitHub repository at
# run time, so re-running this installer picks up any upstream changes.
#
set -u

APP_NAME="HMW A321neo Installer"
GITHUB_REPO="https://github.com/lukaskoledic/HMW_A321Neo_Lukas_Koledic.git"
GITHUB_BRANCH="main"
AIRCRAFT_DIR_NAME="HMW_A321Neo_AppleSilicon_Dev"

# ---------------------------------------------------------------------------
# UI helpers
# ---------------------------------------------------------------------------
UI_MODE="auto"
if [ -t 1 ]; then UI_MODE="tty"; fi

say()  { [ "$UI_MODE" = "tty" ] && printf '%s\n' "$*"; return 0; }
step() { say ""; say "==> $*"; }
ok()   { say "    [ok] $*"; }
warn() { say "    [!!] $*"; }
die()  { say "    [XX] $*"; }

notify() {
    if command -v osascript >/dev/null 2>&1; then
        osascript -e "display notification \"$1\" with title \"$APP_NAME\"" >/dev/null 2>&1 || true
    fi
}

ask() {
    # ask <prompt> <default> -> echoes answer
    local prompt="$1" default="$2" answer
    if [ "$UI_MODE" = "tty" ]; then
        read -r -p "$prompt [$default]: " answer
        echo "${answer:-$default}"
    else
        answer=$(osascript -e "display dialog \"$prompt\" default answer \"$default\" with title \"$APP_NAME\" buttons {\"Cancel\", \"OK\"} default button \"OK\"" 2>/dev/null) || return 1
        printf '%s' "$answer" | sed -e 's/^.*text returned,//' -e 's/^"//' -e 's/"$//'
    fi
}

confirm() {
    local prompt="$1"
    if [ "$UI_MODE" = "tty" ]; then
        read -r -p "$prompt [y/N]: " a
        [ "$a" = "y" ] || [ "$a" = "Y" ]
    else
        osascript -e "display dialog \"$prompt\" buttons {\"Cancel\", \"OK\"} default button \"OK\" with title \"$APP_NAME\"" >/dev/null 2>&1
    fi
}

# ---------------------------------------------------------------------------
# Locate X-Plane 12
# ---------------------------------------------------------------------------
find_xplane() {
    local candidates=(
        "/Applications/X-Plane 12.app/Contents/Resources/X-Plane 12.app/Contents/Resources"
        "/Applications/X-Plane 12.app/Contents/Resources"
        "/Applications/X-Plane 12.app"
        "$HOME/Applications/X-Plane 12.app"
        "/Volumes/X-Plane 12"
        "$HOME/X-Plane 12"
        "/Applications/X-Plane 12"
    )
    for c in "${candidates[@]}"; do
        if [ -d "$c" ] && [ -d "$c/Aircraft" ]; then
            printf '%s' "$c"
            return 0
        fi
    done
    # Last resort: search the Applications folder
    local found
    found=$(find /Applications "$HOME/Applications" -maxdepth 4 -type d -name "Aircraft" 2>/dev/null | head -1)
    if [ -n "$found" ]; then
        printf '%s' "$(dirname "$found")"
        return 0
    fi
    return 1
}

AIRCRAFT_ROOT=""
TARGET_DIR=""

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
step "HMW A321neo Installer"
say ""

# --- 1. Locate X-Plane -------------------------------------------------
step "Locating X-Plane 12"
if AIRCRAFT_ROOT=$(find_xplane); then
    ok "Found: $AIRCRAFT_ROOT"
    TARGET_DIR="$AIRCRAFT_ROOT/Aircraft/$AIRCRAFT_DIR_NAME"
else
    warn "X-Plane 12 was not found automatically."
    chosen=$(ask "Path to your X-Plane 12 folder" "$HOME/X-Plane 12") || {
        die "Cancelled."
        exit 1
    }
    if [ ! -d "$chosen/Aircraft" ]; then
        die "No 'Aircraft' folder found inside: $chosen"
        exit 1
    fi
    AIRCRAFT_ROOT="$chosen"
    TARGET_DIR="$AIRCRAFT_ROOT/Aircraft/$AIRCRAFT_DIR_NAME"
    ok "Using: $AIRCRAFT_ROOT"
fi

# --- 2. Check git --------------------------------------------------------
step "Checking requirements"
if ! command -v git >/dev/null 2>&1; then
    die "git is required to download the aircraft. Install Xcode Command Line Tools and retry."
    exit 1
fi
ok "git $(git --version | awk '{print $3}')"

if ! command -v rsync >/dev/null 2>&1; then
    die "rsync is required. It ships with macOS; please report this."
    exit 1
fi
ok "rsync available"

# --- 3. Download ---------------------------------------------------------
WORKDIR=$(mktemp -d "${TMPDIR:-/tmp}/hmw-a321neo.XXXXXX")
cleanup() { rm -rf "$WORKDIR"; }
trap cleanup EXIT INT TERM

CLONE_DIR="$WORKDIR/repo"

step "Downloading latest $GITHUB_BRANCH from GitHub"
say "    $GITHUB_REPO"
notify "Downloading HMW A321neo..."

GITHUB_API="https://api.github.com/repos/lukaskoledic/HMW_A321Neo_Lukas_Koledic"
BRANCH_TARBALL="https://codeload.github.com/lukaskoledic/HMW_A321Neo_Lukas_Koledic/tar.gz/refs/heads/$GITHUB_BRANCH"

DL_OK=0
DL_METHOD=""

# ---------------------------------------------------------------------------
# 1. Preferred: a published GitHub Release asset (smallest, fastest download)
# ---------------------------------------------------------------------------
if command -v curl >/dev/null 2>&1; then
    REL_JSON=$(curl -fsL --connect-timeout 20 "$GITHUB_API/releases/latest" 2>/dev/null || true)
    ASSET_URL=$(printf '%s' "$REL_JSON" | sed -n 's/.*"browser_download_url": *"\([^"]*\.zip\)".*/\1/p' | head -1)
    if [ -n "$ASSET_URL" ]; then
        say "    Release asset found - downloading..."
        if curl -fL --retry 3 --retry-delay 2 --connect-timeout 20 \
                 -o "$WORKDIR/aircraft.zip" "$ASSET_URL" 2>/dev/null; then
            say "    Extracting..."
            if mkdir -p "$CLONE_DIR" && unzip -q "$WORKDIR/aircraft.zip" -d "$CLONE_DIR" 2>/dev/null; then
                # Handle a single top-level directory inside the archive
                if [ ! -f "$CLONE_DIR/A321.acf" ]; then
                    INNER=$(find "$CLONE_DIR" -maxdepth 2 -name A321.acf -type f 2>/dev/null | head -1)
                    if [ -n "$INNER" ]; then
                        SRC=$(dirname "$INNER")
                        rm -rf "$CLONE_DIR"/*
                        mv "$SRC"/* "$CLONE_DIR"/ 2>/dev/null
                    fi
                fi
                DL_OK=1
                DL_METHOD="release asset"
            fi
        fi
    fi
fi

# ---------------------------------------------------------------------------
# 2. Fallback: branch source tarball (single HTTP request)
# ---------------------------------------------------------------------------
if [ "$DL_OK" -eq 0 ] && command -v curl >/dev/null 2>&1; then
    say "    Fetching branch archive (this aircraft is ~1.8 GB, please be patient)..."
    if curl -fL --retry 3 --retry-delay 2 --connect-timeout 20 \
             -o "$WORKDIR/archive.tar.gz" "$BRANCH_TARBALL" 2>/dev/null; then
        say "    Extracting..."
        if mkdir -p "$CLONE_DIR" && tar -xzf "$WORKDIR/archive.tar.gz" -C "$CLONE_DIR" --strip-components=1 2>/dev/null; then
            DL_OK=1
            DL_METHOD="branch archive"
        fi
    fi
fi

# ---------------------------------------------------------------------------
# 3. Last resort: git clone
# ---------------------------------------------------------------------------
if [ "$DL_OK" -eq 0 ]; then
    say "    Falling back to git clone..."
    if git clone --depth 1 --branch "$GITHUB_BRANCH" "$GITHUB_REPO" "$CLONE_DIR" 2>&1 | sed 's/^/    /'; then
        DL_OK=1
        DL_METHOD="git clone"
    fi
fi

if [ "$DL_OK" -ne 1 ]; then
    die "Download failed. Check your network connection and try again."
    exit 1
fi
ok "Download complete ($DL_METHOD)"

if [ ! -f "$CLONE_DIR/A321.acf" ]; then
    die "Downloaded repository does not contain A321.acf - the download may be incomplete."
    exit 1
fi

# Show what we got
COMMIT=$(git -C "$CLONE_DIR" rev-parse --short HEAD 2>/dev/null || echo "")
SUBJECT=$(git -C "$CLONE_DIR" log -1 --pretty=%s 2>/dev/null || echo "")

if [ -z "$COMMIT" ]; then
    # Tarball download: ask the GitHub API for the head commit of the branch
    if command -v curl >/dev/null 2>&1; then
        API_JSON=$(curl -fsL --connect-timeout 15 \
            "https://api.github.com/repos/lukaskoledic/HMW_A321Neo_Lukas_Koledic/commits/$GITHUB_BRANCH" 2>/dev/null)
        COMMIT=$(printf '%s' "$API_JSON" | sed -n 's/.*"sha": *"\([0-9a-f]\{7,40\}\)".*/\1/p' | head -1)
        SUBJECT=$(printf '%s' "$API_JSON" | sed -n 's/.*"message": *"\([^"]*\)".*/\1/p' | head -1)
    fi
fi
[ -z "$COMMIT" ] && COMMIT="unknown"
ok "Commit $COMMIT"
[ -n "$SUBJECT" ] && say "    $SUBJECT"

# --- 4. Install ----------------------------------------------------------
step "Installing to $TARGET_DIR"

PRESERVE=""

if [ -d "$TARGET_DIR" ]; then
    if confirm "An existing installation was found. Replace it with the latest version?"; then
        ok "Updating existing installation"
    else
        step "Cancelled - nothing was changed"
        exit 0
    fi
    # Preserve user-specific content across the update
    PRESERVE="$WORKDIR/preserve"
    mkdir -p "$PRESERVE"
    for item in "liveries" "A321_prefs.txt" "A321_icon11.png" "A321_icon11_thumb.png"; do
        if [ -e "$TARGET_DIR/$item" ]; then
            cp -R "$TARGET_DIR/$item" "$PRESERVE/" 2>/dev/null || true
        fi
    done
    mkdir -p "$PRESERVE/saved_configs" "$PRESERVE/configuration"
    [ -d "$TARGET_DIR/plugins/sasl/data/modules/Custom Module/saved_configs" ] && \
        cp -R "$TARGET_DIR/plugins/sasl/data/modules/Custom Module/saved_configs/." "$PRESERVE/saved_configs/" 2>/dev/null
    [ -f "$TARGET_DIR/plugins/sasl/data/modules/configuration/wprefs.ini" ] && \
        cp "$TARGET_DIR/plugins/sasl/data/modules/configuration/wprefs.ini" "$PRESERVE/configuration/" 2>/dev/null
    rm -rf "$TARGET_DIR"
else
    ok "Fresh installation"
fi

mkdir -p "$(dirname "$TARGET_DIR")"
rsync -a --exclude='.git' --exclude='.DS_Store' "$CLONE_DIR/" "$TARGET_DIR/" || {
    die "Failed to copy files into $TARGET_DIR"
    exit 1
}
ok "Files copied"

# Restore preserved user content
if [ -n "$PRESERVE" ] && [ -d "$PRESERVE" ]; then
    for item in "liveries" "A321_prefs.txt" "A321_icon11.png" "A321_icon11_thumb.png"; do
        if [ -e "$PRESERVE/$item" ]; then
            cp -R "$PRESERVE/$item" "$TARGET_DIR/" 2>/dev/null || true
        fi
    done
    if [ -d "$PRESERVE/saved_configs" ]; then
        mkdir -p "$TARGET_DIR/plugins/sasl/data/modules/Custom Module/saved_configs"
        cp -R "$PRESERVE/saved_configs/." "$TARGET_DIR/plugins/sasl/data/modules/Custom Module/saved_configs/" 2>/dev/null || true
    fi
    if [ -f "$PRESERVE/configuration/wprefs.ini" ]; then
        mkdir -p "$TARGET_DIR/plugins/sasl/data/modules/configuration"
        cp "$PRESERVE/configuration/wprefs.ini" "$TARGET_DIR/plugins/sasl/data/modules/configuration/" 2>/dev/null || true
    fi
    ok "User content preserved"
fi

# --- 5. Verify -----------------------------------------------------------
step "Verifying installation"
if [ -f "$TARGET_DIR/A321.acf" ]; then
    ok "A321.acf present"
else
    die "A321.acf missing after install - the install did not complete correctly."
    exit 1
fi

OBJ_COUNT=$(find "$TARGET_DIR/objects" -name '*.obj' 2>/dev/null | wc -l | tr -d ' ')
LUA_COUNT=$(find "$TARGET_DIR/plugins" -name '*.lua' 2>/dev/null | wc -l | tr -d ' ')
TEX_COUNT=$(find "$TARGET_DIR/objects" -name '*.png' 2>/dev/null | wc -l | tr -d ' ')
ok "$OBJ_COUNT object meshes, $TEX_COUNT textures, $LUA_COUNT Lua modules"

# --- 6. Done -------------------------------------------------------------
step "Installation complete"
say ""
say "    Aircraft : $AIRCRAFT_ROOT/Aircraft"
say "    Folder   : $AIRCRAFT_DIR_NAME"
say "    Version  : $COMMIT"
say ""
say "    Launch X-Plane 12 and select the HMW A321neo from the aircraft menu."
say ""

notify "HMW A321neo installed successfully"

if [ "$UI_MODE" != "tty" ]; then
    osascript -e "display dialog \"HMW A321neo installed successfully.\n\nVersion: $COMMIT\n\nLaunch X-Plane 12 and select the aircraft from the menu.\" with title \"$APP_NAME\" buttons {\"OK\"} default button \"OK\" with icon note" >/dev/null 2>&1
fi

exit 0
