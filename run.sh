#!/usr/bin/env bash
#
# run.sh – orchestrator for the CachyOS post-install stage scripts
#
# Responsibilities:
#   1. Basic environment / connectivity checks (Arch + AUR + CachyOS)
#   2. Enable multilib (if needed)
#   3. Full system update (pacman -Syu)
#   4. Ensure yay + Python 3 are present
#   5. Run the numbered stage scripts in order
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
STAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGES=(
  "1_hardware.py"
  # Add more stages here later, e.g.:
  # "02-desktop-environment.py"
  # "03-applications.py"
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }           # bold green
warn()  { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }         # bold yellow
error() { printf '\033[1;31m==>\033[0m %s\n' "$*" >&2; exit 1; } # bold red

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || error "Required command not found: $1"
}

check_url() {
  local url="$1"
  local label="$2"
  if curl -sS --connect-timeout 5 --max-time 10 -o /dev/null "$url"; then
    echo "    ✓ $label"
  else
    error "Cannot reach $label ($url) – check your network"
  fi
}

# ---------------------------------------------------------------------------
# Pre-flight
# ---------------------------------------------------------------------------
if [[ $EUID -eq 0 ]]; then
  error "Do not run this script as root. It will call sudo when needed."
fi

need_cmd curl
need_cmd pacman
need_cmd sudo

info "Checking repository connectivity"
check_url "https://archlinux.org"     "Official Arch repositories"
check_url "https://aur.archlinux.org" "AUR"

# ---------------------------------------------------------------------------
# Enable multilib (required for 32-bit Mesa / Vulkan / Steam / Proton)
# ---------------------------------------------------------------------------
info "Ensuring multilib repository is enabled"

if grep -qE '^\s*\[multilib\]' /etc/pacman.conf; then
  echo "    multilib already enabled"
else
  echo "    Enabling multilib..."

  # Case 1: the block exists but is commented out → uncomment it
  if grep -qE '^\s*#\[multilib\]' /etc/pacman.conf; then
    sudo sed -i '/^#\[multilib\]/,/^#Include = \/etc\/pacman.d\/mirrorlist/{
      s/^#\[multilib\]/[multilib]/
      s/^#Include = \/etc\/pacman.d\/mirrorlist/Include = \/etc\/pacman.d\/mirrorlist/
    }' /etc/pacman.conf
  else
    # Case 2: the block was deleted → append a fresh one
    echo "" | sudo tee -a /etc/pacman.conf >/dev/null
    cat << 'EOF' | sudo tee -a /etc/pacman.conf >/dev/null
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
  fi
fi

# ---------------------------------------------------------------------------
# Full system update
# ---------------------------------------------------------------------------
info "Running full system update (pacman -Syu)"
sudo pacman -Syu --noconfirm

# ---------------------------------------------------------------------------
# Install yay via pacman (CachyOS repos ship it)
# ---------------------------------------------------------------------------
info "Ensuring yay is installed"
sudo pacman -S --needed --noconfirm yay

# ---------------------------------------------------------------------------
# Install Python via yay
# ---------------------------------------------------------------------------
info "Ensuring Python is installed"
yay -S --needed --noconfirm python

# ---------------------------------------------------------------------------
# Run stage scripts
# ---------------------------------------------------------------------------
info "Starting stage scripts"

for stage in "${STAGES[@]}"; do
  script="$STAGE_DIR/$stage"

  if [[ ! -f "$script" ]]; then
    warn "Stage not found, skipping: $stage"
    continue
  fi

  info "Running $stage"
  # bash has no SIGINT trap by default, so on Ctrl-C it would normally die
  # immediately — racing against (and often outrunning) the stage script's
  # own signal handler, which needs to run first to restore the terminal
  # and re-enable snap-pac. Ignoring SIGINT here only pauses bash's own
  # reaction; python3 still receives and handles its own copy of the
  # signal via signal.signal(), so Ctrl-C still works, it just completes
  # cleanly instead of racing.
  trap '' INT
  if python3 "$script"; then
    status=0
  else
    status=$?
  fi
  trap - INT

  if [[ $status -ne 0 ]]; then
    error "$stage exited with status $status"
  fi
done

info "All stages completed successfully"
