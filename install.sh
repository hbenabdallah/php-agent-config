#!/usr/bin/env bash
# Installs what applies to every project, for the current user:
#   ~/.claude/rules/agent-engineering.md   the engineering rules, loaded in every session
#   ~/.claude/skills/                      review-changes, refactor-safely, write-tests
#   ~/.agents/skills/                      the same skills, for agents reading the shared skills folder
# Usage: curl -fsSL https://raw.githubusercontent.com/hbenabdallah/php-agent-config/main/install.sh | bash
# Run again to update. AGENT_CONFIG_REF selects a tag, branch or commit (default: main).
set -euo pipefail

source_dir=$(cd "$(dirname "${BASH_SOURCE[0]:-.}")" && pwd)
if [[ ! -f "$source_dir/lib/install-common.sh" ]]; then
    source_dir=$(mktemp -d)
    trap 'rm -rf "$source_dir"' EXIT
    curl -fsSL "https://github.com/hbenabdallah/php-agent-config/archive/${AGENT_CONFIG_REF:-main}.tar.gz" \
        | tar -xz --strip-components=1 -C "$source_dir"
fi
# shellcheck source=lib/install-common.sh
. "$source_dir/lib/install-common.sh"

config=${CLAUDE_CONFIG_DIR:-$HOME/.claude}

mkdir -p "$config/rules"
cp "$source_dir/global/rules/agent-engineering.md" "$config/rules/agent-engineering.md"

install_skills "$source_dir/global/skills" "$config/skills"
install_skills "$source_dir/global/skills" "$HOME/.agents/skills"

echo "Installed globally: rules in $config/rules, skills in $config/skills and $HOME/.agents/skills."
