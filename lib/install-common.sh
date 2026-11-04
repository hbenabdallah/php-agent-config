#!/usr/bin/env bash
# Shared by install-global.sh and install-php.sh.

marker=.installed-by-php-agent-config

# A skill carrying the marker is ours: it is replaced, or removed once gone from the source. Any other is left alone.
install_skills() {
    local source=$1 dest=$2 skill name
    mkdir -p "$dest"
    for skill in "$dest"/*/; do
        [[ -f "$skill$marker" ]] || continue
        name=$(basename "$skill")
        if [[ ! -d "$source/$name" ]]; then
            rm -rf "${dest:?}/$name"
        fi
    done
    for skill in "$source"/*/; do
        name=$(basename "$skill")
        if [[ -e "$dest/$name" && ! -f "$dest/$name/$marker" ]]; then
            echo "Skipped $dest/$name: it was not installed from here." >&2
            continue
        fi
        rm -rf "${dest:?}/$name"
        cp -R "$skill" "$dest/$name"
        touch "$dest/$name/$marker"
    done
}
