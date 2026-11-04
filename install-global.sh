#!/usr/bin/env bash
# Installs what applies to every project, for the current user:
#   ~/.claude/rules/agent-engineering.md   the engineering rules, loaded in every session
#   ~/.claude/skills/                      review-changes, refactor-safely, write-tests
#   ~/.agents/skills/                      the same skills, for agents reading the shared skills folder
# Usage: install-global.sh. Run again to update.
set -euo pipefail

source_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=lib/install-common.sh
. "$source_dir/lib/install-common.sh"

config=${CLAUDE_CONFIG_DIR:-$HOME/.claude}

mkdir -p "$config/rules"
cp "$source_dir/global/rules/agent-engineering.md" "$config/rules/agent-engineering.md"

install_skills "$source_dir/global/skills" "$config/skills"
install_skills "$source_dir/global/skills" "$HOME/.agents/skills"

echo "Installed globally: rules in $config/rules, skills in $config/skills and $HOME/.agents/skills."
