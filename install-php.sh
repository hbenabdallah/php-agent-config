#!/usr/bin/env bash
# Installs the PHP layer into one project:
#   .claude/rules/php.md   the PHP rules, loaded when a PHP file is opened
#   .agents/overlays/      the PHP steps of review-changes, refactor-safely and write-tests
#   .claude/skills/        php-quality-setup, for Claude Code
#   .agents/skills/        php-quality-setup, for agents reading the shared skills folder
#   AGENTS.md              a pointer to the rules, unless the project has its own
#   CLAUDE.md              created, or completed, with an import of that AGENTS.md
# All of it is ignored by git in that clone (.git/info/exclude), except a CLAUDE.md that already existed.
# Also migrates an install made by the former install.sh.
# Usage: install-php.sh [project directory] (default: the current directory). Run again to update.
set -euo pipefail

source_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
target=$(cd "${1:-.}" && pwd)
# shellcheck source=lib/install-common.sh
. "$source_dir/lib/install-common.sh"

if [[ ! -f "$target/composer.json" ]]; then
    echo "No composer.json in $target: not a PHP project?" >&2
    exit 1
fi

exclude=
if exclude=$(git -C "$target" rev-parse --path-format=absolute --git-path info/exclude 2>/dev/null); then
    mkdir -p "$(dirname "$exclude")"
    touch "$exclude"
fi

is_ours() {
    [[ -n $exclude ]] && grep -qxF "$1" "$exclude" && [[ -z $(git -C "$target" ls-files -- "$2") ]]
}

remove_former_skills() {
    local name
    for name in php-review php-refactor php-test php-quality-setup; do
        if [[ -d "$target/.claude/skills/$name" && ! -f "$target/.claude/skills/$name/$marker" ]]; then
            if is_ours "/.claude/skills/$name/" ".claude/skills/$name"; then
                rm -rf "${target:?}/.claude/skills/$name"
            else
                echo "Left .claude/skills/$name in place: it does not look installed from here." >&2
            fi
        fi
        if [[ -d "$target/.agents/skills/$name" && ! -f "$target/.agents/skills/$name/$marker" ]]; then
            if is_ours /.agents/ ".agents/skills/$name"; then
                rm -rf "${target:?}/.agents/skills/$name"
            else
                echo "Left .agents/skills/$name in place: it does not look installed from here." >&2
            fi
        fi
    done
}

remove_import() {
    local file=$1 import=$2 kept
    [[ -f "$file" ]] && grep -qxF "$import" "$file" || return 0
    kept=$(grep -vxF "$import" "$file" || true)
    if [[ -z ${kept//[$'\n\t ']/} ]]; then
        rm "$file"
    else
        printf '%s\n' "$kept" > "$file"
    fi
}

mkdir -p "$target/.claude/rules" "$target/.agents/overlays"
if [[ -n $exclude && -n $(git -C "$target" ls-files -- .claude/rules/php.md) ]]; then
    echo "Skipped .claude/rules/php.md: the project tracks its own." >&2
else
    cp "$source_dir/php/rules.md" "$target/.claude/rules/php.md"
fi
cp "$source_dir"/php/overlays/*.md "$target/.agents/overlays/"

remove_former_skills
install_skills "$source_dir/php/skills" "$target/.claude/skills"
install_skills "$source_dir/php/skills" "$target/.agents/skills"

# An AGENTS.md installed here before is updated, keeping its project sections ("## This project…" to the end).
# Any other AGENTS.md is the project's own and stays untouched.
heading=$(head -n 1 "$source_dir/php/AGENTS.md")
own_agents=false
if [[ -f "$target/AGENTS.md" ]] && [[ $(head -n 1 "$target/AGENTS.md") == "$heading" ]]; then
    project=$(awk '/^## This project/ { found = 1 } found' "$target/AGENTS.md")
    cp "$source_dir/php/AGENTS.md" "$target/AGENTS.md"
    if [[ -n $project ]]; then
        printf '\n%s\n' "$project" >> "$target/AGENTS.md"
    fi
elif [[ -f "$target/AGENTS.md" ]]; then
    own_agents=true
    echo "AGENTS.md is the project's own. For agents other than Claude Code, add: $(tail -n 1 "$source_dir/php/AGENTS.md")"
else
    cp "$source_dir/php/AGENTS.md" "$target/AGENTS.md"
fi

# The former install.sh could write the whole rules to AGENTS.php.md and import them.
if [[ -f "$target/AGENTS.php.md" ]] && [[ $(head -n 1 "$target/AGENTS.php.md") == "$heading" ]]; then
    rm "$target/AGENTS.php.md"
    remove_import "$target/CLAUDE.md" "@AGENTS.php.md"
    remove_import "$target/.claude/CLAUDE.md" "@../AGENTS.php.md"
fi

ignored=(/.agents/ /.claude/rules/php.md /.claude/skills/php-quality-setup/)

# Imports are relative to the file holding them; a project keeping its instructions in .claude/CLAUDE.md keeps them there.
if [[ $own_agents == false ]]; then
    ignored+=(/AGENTS.md)
    claude=CLAUDE.md
    import="@AGENTS.md"
    if [[ ! -f "$target/CLAUDE.md" && -f "$target/.claude/CLAUDE.md" ]]; then
        claude=.claude/CLAUDE.md
        import="@../AGENTS.md"
    fi
    if [[ ! -f "$target/$claude" ]]; then
        printf '%s\n' "$import" > "$target/$claude"
        ignored+=("/$claude")
    elif ! grep -qxF "$import" "$target/$claude"; then
        printf '\n%s\n' "$import" >> "$target/$claude"
    fi
fi

if [[ -n $exclude ]]; then
    for entry in "${ignored[@]}"; do
        grep -qxF "$entry" "$exclude" || printf '%s\n' "$entry" >> "$exclude"
        if [[ -n $(git -C "$target" ls-files -- "${entry#/}") ]]; then
            echo "Warning: ${entry#/} is already tracked by git; ignoring it has no effect until it is removed from the index (git rm --cached)." >&2
        fi
    done
    echo "Ignored in $exclude: ${ignored[*]}"
else
    echo "Not a git repository: nothing ignored."
fi

if [[ ! -d "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/review-changes" ]]; then
    echo "The PHP overlays complete the global skills: run install-global.sh once on this machine." >&2
fi

echo "Installed in $target: PHP rules, overlays and php-quality-setup."
