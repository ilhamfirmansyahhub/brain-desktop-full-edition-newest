#!/usr/bin/env bash
# Brain Desktop Full Edition — portable Arch/CachyOS + Hyprland installer

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

QS_DIR="$HOME/.config/quickshell/brain-desktop"
BRAIN_CFG="$HOME/.config/Brain_Shell"
USER_DATA="$BRAIN_CFG/src/user_data"

USER_SYSTEMD="$HOME/.config/systemd/user"
SERVICE="$USER_SYSTEMD/brain-desktop.service"

HYPR_DIR="$HOME/.config/hypr"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info() {
    echo -e "  ${CYAN}·${NC} $1"
}

ok() {
    echo -e "  ${GREEN}✓${NC} $1"
}

warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

die() {
    echo -e "  ${RED}✗${NC} $1" >&2
    exit 1
}

# ============================================================================
# Validation
# ============================================================================

[[ "${EUID}" -ne 0 ]] \
    || die "Run this installer as your normal user, not root."

[[ -f /etc/os-release ]] \
    || die "Cannot detect Linux distribution."

# shellcheck disable=SC1091
source /etc/os-release

[[ "${ID:-}" == "arch" || "${ID_LIKE:-}" == *arch* ]] \
    || die "Brain Desktop currently supports Arch-based systems."

command -v pacman >/dev/null 2>&1 \
    || die "pacman is required."

command -v hyprctl >/dev/null 2>&1 \
    || die "Hyprland is required. Start/setup Hyprland first."

command -v quickshell >/dev/null 2>&1 \
    || warn "Quickshell is not installed yet. It will be installed."

# ============================================================================
# Backup existing Brain Desktop installation
# ============================================================================

BACKUP="$HOME/.config.backup-$(date +%Y%m%d_%H%M%S)-Brain_Desktop"

mkdir -p "$BACKUP"
mkdir -p "$USER_SYSTEMD"

if [[ -d "$QS_DIR" ]]; then
    cp -a "$QS_DIR" "$BACKUP/brain-desktop"
    ok "Existing Brain Desktop backed up"
fi

if [[ -d "$BRAIN_CFG" ]]; then
    mkdir -p "$BACKUP/Brain_Shell"
    cp -a "$BRAIN_CFG/." "$BACKUP/Brain_Shell/" 2>/dev/null || true
    ok "Existing Brain compatibility config backed up"
fi

# ============================================================================
# Dependencies
# ============================================================================

info "Installing runtime dependencies..."

sudo pacman -Syu --needed --noconfirm \
    quickshell \
    qt6-base \
    qt6-declarative \
    qt6-multimedia \
    qt6-5compat \
    pipewire \
    pipewire-pulse \
    wireplumber \
    playerctl \
    mpv-mpris \
    networkmanager \
    bluez \
    bluez-utils \
    brightnessctl \
    upower \
    libnotify \
    polkit \
    python \
    wl-clipboard \
    slurp \
    xdg-user-dirs \
    wf-recorder \
    cava \
    cliphist \
    awww \
    matugen \
    hypridle \
    hyprlock \
    hyprpolkitagent \
    hyprsunset \
    xdg-desktop-portal-hyprland \
    ttf-jetbrains-mono-nerd \
    ttf-nerd-fonts-symbols-common

ok "Dependencies installed"

# ============================================================================
# Install Brain Desktop source
# ============================================================================

info "Installing Brain Desktop..."

rm -rf "$QS_DIR"
mkdir -p "$QS_DIR"

[[ -f "$REPO_DIR/shell.qml" ]] \
    || die "shell.qml is missing from repository."

[[ -d "$REPO_DIR/src" ]] \
    || die "src/ directory is missing from repository."

cp -a "$REPO_DIR/shell.qml" "$QS_DIR/"
cp -a "$REPO_DIR/src" "$QS_DIR/"

if [[ -d "$REPO_DIR/config" ]]; then
    cp -a "$REPO_DIR/config" "$QS_DIR/"
fi

if [[ -d "$REPO_DIR/config_tab" ]]; then
    cp -a "$REPO_DIR/config_tab" "$QS_DIR/"
fi

if [[ -d "$REPO_DIR/scripts" ]]; then
    mkdir -p "$QS_DIR/scripts"
    cp -a "$REPO_DIR/scripts/." "$QS_DIR/scripts/"
fi

chmod +x "$QS_DIR"/src/scripts/*.sh 2>/dev/null || true
chmod +x "$QS_DIR"/src/scripts/*.py 2>/dev/null || true
chmod +x "$QS_DIR"/scripts/*.sh 2>/dev/null || true
chmod +x "$QS_DIR"/scripts/*.py 2>/dev/null || true

ok "Brain Desktop installed to $QS_DIR"

# ============================================================================
# Brain compatibility configuration
#
# Only install static compatibility files.
# Do NOT copy personal runtime/user_data from this machine.
# ============================================================================

info "Installing Brain compatibility configuration..."

mkdir -p "$USER_DATA"
mkdir -p "$HOME/.cache/brain-shell"

if [[ -d "$REPO_DIR/configs/Brain_Shell" ]]; then
    cp -a "$REPO_DIR/configs/Brain_Shell/." "$BRAIN_CFG/"
fi

# Brain uses Hyprland Lua
printf '%s\n' '{"configProvider":"lua"}' \
    > "$USER_DATA/config_Provider.json"

# Start with clean keybind overrides.
# The GUI will populate this file when the user customizes keybinds.
printf '%s\n' '{}' \
    > "$USER_DATA/keybinds.json"

# Clean runtime-generated color cache
printf '%s\n' '{}' \
    > "$HOME/.cache/brain-shell/colors.json"

# Never restore the old updater preference system.
rm -f "$USER_DATA/update_prefs.json"

ok "Brain compatibility configuration installed"

# ============================================================================
# Wallpaper assets
# ============================================================================

if [[ -d "$REPO_DIR/src/assets/wallpapers" ]]; then
    mkdir -p "$HOME/Pictures/Wallpapers"

    cp -an \
        "$REPO_DIR/src/assets/wallpapers/." \
        "$HOME/Pictures/Wallpapers/" \
        || true

    ok "Wallpaper assets installed"
fi

# ============================================================================
# Screenshot scripts
# ============================================================================

SCREENSHOT_AREA="$HOME/.local/bin/screenshot-area"
SCREENSHOT_DISPLAY="$HOME/.local/bin/screenshot-display"

if [[ -f "$REPO_DIR/scripts/screenshot.sh" ]]; then
    mkdir -p "$HOME/.local/bin"

    cp "$REPO_DIR/scripts/screenshot.sh" \
        "$SCREENSHOT_AREA"

    chmod +x "$SCREENSHOT_AREA"

    ok "Area screenshot command installed"
fi

if [[ -f "$REPO_DIR/scripts/screenshot-display.sh" ]]; then
    mkdir -p "$HOME/.local/bin"

    cp "$REPO_DIR/scripts/screenshot-display.sh" \
        "$SCREENSHOT_DISPLAY"

    chmod +x "$SCREENSHOT_DISPLAY"

    ok "Display screenshot command installed"
fi

# ============================================================================
# Brain keybind include
# ============================================================================

KEY_LUA="$BRAIN_CFG/Brain_ShellKeybinds.lua"
KEY_CONF="$BRAIN_CFG/Brain_ShellKeybinds.conf"

MARKER="Brain_Desktop_Keybinds"

if [[ -f "$HYPR_DIR/hyprland.lua" ]]; then

    HYPR="$HYPR_DIR/hyprland.lua"

    if ! grep -qF "$MARKER" "$HYPR"; then
        {
            echo ""
            echo "-- $MARKER"
            printf '%s\n' \
                'dofile(os.getenv("HOME") .. "/.config/Brain_Shell/Brain_ShellKeybinds.lua")'
        } >> "$HYPR"

        ok "Brain keybinds included in hyprland.lua"
    else
        info "Brain keybind include already present"
    fi

elif [[ -f "$HYPR_DIR/hyprland.conf" ]]; then

    HYPR="$HYPR_DIR/hyprland.conf"

    if ! grep -qF "$MARKER" "$HYPR"; then
        {
            echo ""
            echo "# $MARKER"
            printf 'source = %s\n' "$KEY_CONF"
        } >> "$HYPR"

        ok "Brain keybinds included in hyprland.conf"
    else
        info "Brain keybind include already present"
    fi

else
    warn "No Hyprland configuration found."
    warn "Brain keybind files were installed but not auto-included."
fi

# ============================================================================
# Systemd user service
# ============================================================================

info "Installing Brain Desktop service..."

mkdir -p "$USER_SYSTEMD"

cat > "$SERVICE" <<'EOF'
[Unit]
Description=Brain Desktop Top Shell
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/quickshell -c %h/.config/quickshell/brain-desktop
Restart=on-failure
RestartSec=2

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now brain-desktop.service

ok "Brain Desktop service enabled"

# ============================================================================
# Supporting services
# ============================================================================

systemctl --user enable --now \
    pipewire \
    pipewire-pulse \
    wireplumber \
    2>/dev/null || true

sudo systemctl enable --now NetworkManager \
    2>/dev/null || true

sudo systemctl enable --now bluetooth \
    2>/dev/null || true

sudo systemctl enable --now upower \
    2>/dev/null || true

# ============================================================================
# Validation
# ============================================================================

info "Validating installation..."

[[ -f "$QS_DIR/shell.qml" ]] \
    || die "Brain Desktop shell.qml was not installed."

[[ -f "$QS_DIR/src/qmldir" ]] \
    || die "Brain Desktop QML module file is missing."

command -v quickshell >/dev/null 2>&1 \
    || die "quickshell is not available in PATH."

if [[ -f "$KEY_LUA" ]]; then
    ok "Brain Lua keybind file present"
else
    warn "Brain Lua keybind file was not found"
fi

if [[ -f "$SCREENSHOT_AREA" ]]; then
    ok "Area screenshot command present"
fi

if [[ -f "$SCREENSHOT_DISPLAY" ]]; then
    ok "Display screenshot command present"
fi

# Update system has been removed from Full Edition.
if grep -RniE \
    'UpdateService|UpdatePopup|autoUpdate' \
    "$QS_DIR" \
    2>/dev/null; then

    die "Updater references remain in the installed shell."
fi

# Validate service
if systemctl --user is-active --quiet brain-desktop.service; then
    ok "Brain Desktop service is running"
else
    warn "Brain Desktop service is not currently running"
fi

# ============================================================================
# Complete
# ============================================================================

echo ""
echo -e "${BOLD}Brain Desktop Full Edition installation complete.${NC}"
echo ""
echo "Backup : $BACKUP"
echo "Shell  : $QS_DIR"
echo "Config : $BRAIN_CFG"
echo "Service: brain-desktop.service"
echo ""
echo "Personal keybinds/theme/runtime data were intentionally not copied."
echo "They can be configured again from Brain Desktop."
echo ""
echo "Log out and back in if Hyprland does not immediately pick up keybind changes."
