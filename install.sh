#!/usr/bin/env bash
# Installs the PHP agent rules and skills into a project:
#   AGENTS.md            the rules (kept if the project already has one: the rules go to AGENTS.php.md instead)
#   CLAUDE.md            created, or completed, with an import of AGENTS.md (Claude Code reads CLAUDE.md);
#                        .claude/CLAUDE.md instead when the project has only that one
#   .claude/skills/      the skills, for Claude Code
#   .agents/skills/      the skills, for agents reading the shared skills folder (Codex and others)
# All of it is ignored by git in that clone (.git/info/exclude), except a CLAUDE.md that already existed.
# Usage: install.sh [project directory] (default: the current directory). Run again to update the skills.
set -euo pipefail

source_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
target=$(cd "${1:-.}" && pwd)

if [[ ! -f "$target/composer.json" ]]; then
    echo "No composer.json in $target: not a PHP project?" >&2
    exit 1
fi

# An AGENTS.md installed here before is updated, keeping its project sections ("## This project…" to the end).
# Any other AGENTS.md is the project's own: the rules go next to it.
rules=AGENTS.md
heading=$(head -n 1 "$source_dir/AGENTS.md")
if [[ -f "$target/AGENTS.md" ]] && [[ $(head -n 1 "$target/AGENTS.md") == "$heading" ]]; then
    project=$(awk '/^## This project/ { found = 1 } found' "$target/AGENTS.md")
    cp "$source_dir/AGENTS.md" "$target/AGENTS.md"
    [[ -n $project ]] && printf '\n%s\n' "$project" >> "$target/AGENTS.md"
elif [[ -f "$target/AGENTS.md" ]]; then
    rules=AGENTS.php.md
    cp "$source_dir/AGENTS.md" "$target/$rules"
    echo "AGENTS.md is the project's own: rules written to AGENTS.php.md; reference it from AGENTS.md."
else
    cp "$source_dir/AGENTS.md" "$target/AGENTS.md"
fi

# Imports are relative to the file holding them; a project keeping its instructions in .claude/CLAUDE.md keeps them there.
claude=CLAUDE.md
import="@$rules"
if [[ ! -f "$target/CLAUDE.md" && -f "$target/.claude/CLAUDE.md" ]]; then
    claude=.claude/CLAUDE.md
    import="@../$rules"
fi
ignored=("/$rules" /.agents/)
if [[ ! -f "$target/$claude" ]]; then
    printf '%s\n' "$import" > "$target/$claude"
    ignored+=("/$claude")
elif ! grep -qxF "$import" "$target/$claude"; then
    printf '\n%s\n' "$import" >> "$target/$claude"
fi

for dir in .claude/skills .agents/skills; do
    mkdir -p "$target/$dir"
    for skill in "$source_dir"/skills/*/; do
        name=$(basename "$skill")
        rm -rf "${target:?}/$dir/$name"
        cp -R "$skill" "$target/$dir/$name"
        [[ $dir == .claude/skills ]] && ignored+=("/$dir/$name/")
    done
done

# Kept out of git in this clone only: .git/info/exclude is never committed, unlike .gitignore, and unlike a global
# excludes file it doesn't hide AGENTS.md in repositories meant to commit it.
if exclude=$(git -C "$target" rev-parse --path-format=absolute --git-path info/exclude 2>/dev/null); then
    mkdir -p "$(dirname "$exclude")"
    touch "$exclude"
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

echo "Installed in $target: $rules, CLAUDE.md import, skills in .claude/skills and .agents/skills."
