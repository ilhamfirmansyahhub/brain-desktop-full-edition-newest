#!/usr/bin/env bash
# Brain Desktop — portable Arch/Hyprland installer
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
QS_DIR="$HOME/.config/quickshell/brain-desktop"
BRAIN_CFG="$HOME/.config/Brain_Shell"
USER_SYSTEMD="$HOME/.config/systemd/user"
SERVICE="$USER_SYSTEMD/brain-desktop.service"
HYPR_DIR="$HOME/.config/hypr"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
info(){ echo -e "  ${CYAN}·${NC} $1"; }
ok(){ echo -e "  ${GREEN}✓${NC} $1"; }
warn(){ echo -e "  ${YELLOW}⚠${NC} $1"; }
die(){ echo -e "  ${RED}✗${NC} $1" >&2; exit 1; }

[[ "${EUID}" -ne 0 ]] || die "Run this installer as your normal user, not root."
[[ -f /etc/os-release ]] || die "Cannot detect Linux distribution."
source /etc/os-release
[[ "${ID:-}" == "arch" || "${ID_LIKE:-}" == *arch* ]] || die "Brain Desktop currently supports Arch-based systems."
command -v hyprctl >/dev/null 2>&1 || die "Hyprland is required. Start/setup Hyprland first."
command -v pacman >/dev/null 2>&1 || die "pacman is required."

BACKUP="$HOME/.config.backup-$(date +%Y%m%d_%H%M%S)-Brain_Desktop"
mkdir -p "$BACKUP" "$USER_SYSTEMD"

if [[ -d "$QS_DIR" ]]; then
    cp -a "$QS_DIR" "$BACKUP/brain-desktop" && ok "Backed up existing Brain Desktop config"
fi

info "Installing runtime dependencies..."
sudo pacman -Syu --needed --noconfirm \
    quickshell \
    qt6-base qt6-declarative qt6-multimedia qt6-5compat \
    pipewire pipewire-pulse wireplumber \
    playerctl mpv-mpris \
    networkmanager bluez bluez-utils \
    brightnessctl upower libnotify polkit \
    python wl-clipboard slurp xdg-user-dirs \
    wf-recorder cava cliphist \
    awww matugen \
    hypridle hyprlock hyprpolkitagent hyprsunset \
    xdg-desktop-portal-hyprland \
    ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols-common
ok "Dependencies installed"

rm -rf "$QS_DIR"
mkdir -p "$QS_DIR"
cp -a "$REPO_DIR/shell.qml" "$REPO_DIR/src" "$QS_DIR/"
chmod +x "$QS_DIR"/src/scripts/*.sh "$QS_DIR"/src/scripts/*.py 2>/dev/null || true
ok "Brain Desktop installed to $QS_DIR"

mkdir -p "$BRAIN_CFG/src/user_data" "$HOME/.cache/brain-shell"
cp -a "$REPO_DIR/configs/Brain_Shell/"*.lua "$BRAIN_CFG/" 2>/dev/null || true
cp -a "$REPO_DIR/configs/Brain_Shell/"*.conf "$BRAIN_CFG/" 2>/dev/null || true
printf '{"configProvider":"lua"}\n' > "$BRAIN_CFG/src/user_data/config_Provider.json"
printf '{}\n' > "$BRAIN_CFG/src/user_data/keybinds.json"
printf '{}\n' > "$HOME/.cache/brain-shell/colors.json"
rm -f "$BRAIN_CFG/src/user_data/update_prefs.json"
ok "Brain compatibility config installed"

if [[ -d "$REPO_DIR/src/assets/wallpapers" ]]; then
    mkdir -p "$HOME/Pictures/Wallpapers"
    cp -an "$REPO_DIR/src/assets/wallpapers/." "$HOME/Pictures/Wallpapers/" || true
    ok "Wallpapers installed"
fi

KEY_LUA="$BRAIN_CFG/Brain_ShellKeybinds.lua"
KEY_CONF="$BRAIN_CFG/Brain_ShellKeybinds.conf"
MARKER="Brain_Desktop_Keybinds"

if [[ -f "$HYPR_DIR/hyprland.lua" ]]; then
    HYPR="$HYPR_DIR/hyprland.lua"
    if ! grep -qF "$MARKER" "$HYPR"; then
        {
            echo ""
            echo "-- $MARKER"
            printf 'dofile(os.getenv("HOME") .. "/.config/Brain_Shell/Brain_ShellKeybinds.lua")\n'
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
    warn "No Hyprland config found; keybinds were installed but not auto-included."
fi

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

systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true
sudo systemctl enable --now NetworkManager 2>/dev/null || true
sudo systemctl enable --now bluetooth 2>/dev/null || true
sudo systemctl enable --now upower 2>/dev/null || true

[[ -f "$QS_DIR/shell.qml" ]] || die "Brain Desktop shell.qml was not installed."
[[ -f "$QS_DIR/src/qmldir" ]] || die "Brain Desktop QML module file is missing."
command -v quickshell >/dev/null 2>&1 || die "quickshell is not available in PATH."

if grep -RniE 'UpdateService|UpdatePopup|autoUpdate' "$QS_DIR" 2>/dev/null; then
    die "Auto-update references remain in the installed shell."
fi

ok "Validation passed"
echo ""
echo -e "${BOLD}Brain Desktop installation complete.${NC}"
echo "Backup: $BACKUP"
echo "Shell:  $QS_DIR"
echo "Service: brain-desktop.service"
echo ""
echo "Log out and back in if Hyprland does not immediately pick up the new keybind include."
