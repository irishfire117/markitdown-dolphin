#!/usr/bin/env bash
# Install (or remove, with --uninstall) the "Convert to Markdown" Dolphin action
# for the current user. No root needed.
set -euo pipefail

src="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
data="${XDG_DATA_HOME:-$HOME/.local/share}"
bindir="$HOME/.local/bin"

script="$bindir/markitdown-convert"
servicemenu="$data/kio/servicemenus/markitdown.desktop"
appentry="$data/applications/markitdown-convert.desktop"

if [[ "${1:-}" == "--uninstall" ]]; then
    rm -fv "$script" "$servicemenu" "$appentry"
    echo "Uninstalled."
    exit 0
fi

# Dependencies
missing=0
if ! python3 -c 'import gi; from gi.repository import Gio' 2>/dev/null; then
    echo "Missing: PyGObject for python3 (Arch: python-gobject, Debian/Ubuntu: python3-gi, Fedora: python3-gobject)" >&2
    missing=1
fi
if ! command -v notify-send >/dev/null; then
    echo "Missing: notify-send (Arch: libnotify, Debian/Ubuntu: libnotify-bin)" >&2
    missing=1
fi
(( missing )) && exit 1

if ! command -v markitdown >/dev/null && [[ ! -x "$bindir/markitdown" ]]; then
    echo "Warning: markitdown not found. Install it with: pipx install 'markitdown[all]'" >&2
fi

install -Dm755 "$src/markitdown-convert" "$script"
mkdir -p "$(dirname "$servicemenu")" "$(dirname "$appentry")"
sed "s|@BINDIR@|$bindir|" "$src/markitdown-servicemenu.desktop" > "$servicemenu"
sed "s|@BINDIR@|$bindir|" "$src/markitdown-convert.desktop" > "$appentry"
chmod 755 "$servicemenu"   # KF6 ignores service menus that aren't executable

echo "Installed:"
echo "  $script"
echo "  $servicemenu"
echo "  $appentry"
echo "Right-click a supported file in Dolphin and choose \"Convert to Markdown\"."
echo "If the entry doesn't appear, close and reopen Dolphin."
