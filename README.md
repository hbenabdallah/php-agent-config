# php-agent-config

Coding rules and skills for AI coding agents (Claude Code, Codex, Copilot, Cursor and others), in two layers: a global
layer that fits any project, and a PHP layer added per project. Rules stay out of the context until they are needed.

The PHP rules are technical, not architectural: types, classes, control flow, errors, security and tooling, on top of
PSR-1, PSR-4 and PER Coding Style 2.0. The project's instructions and tooling configuration always win, then the code
already there, then these rules.

## Install

Once per machine, the global layer:

```sh
curl -fsSL https://raw.githubusercontent.com/hbenabdallah/php-agent-config/main/install.sh | bash
```

Once per PHP project, from its root, the PHP layer:

```sh
curl -fsSL https://raw.githubusercontent.com/hbenabdallah/php-agent-config/main/install-php.sh | bash
```

To target another folder, end the command with `| bash -s -- path/to/project`. Run the same commands again to update.
Both need `curl` and `tar`, and install from `main`: set `AGENT_CONFIG_REF` on `bash` to pin a tag or commit
(`| AGENT_CONFIG_REF=v1.0.0 bash`). From a clone, run `./install.sh` and `./install-php.sh path/to/project` directly.

## Contents

| Path | Installed to | Loaded |
|---|---|---|
| [`global/rules/agent-engineering.md`](global/rules/agent-engineering.md) | `~/.claude/rules/` | Every session |
| [`global/skills/review-changes`](global/skills/review-changes/SKILL.md) | `~/.claude/skills/`, `~/.agents/skills/` | Description always, body on use, in a forked context |
| [`global/skills/refactor-safely`](global/skills/refactor-safely/SKILL.md) | same | Description always, body on use |
| [`global/skills/write-tests`](global/skills/write-tests/SKILL.md) | same | Description always, body on use |
| [`php/rules.md`](php/rules.md) | `.claude/rules/php.md` | When a `.php` file is opened |
| [`php/overlays/`](php/overlays) | `.agents/overlays/` | When the matching global skill runs |
| [`php/skills/php-quality-setup`](php/skills/php-quality-setup/SKILL.md) | `.claude/skills/`, `.agents/skills/` | Only on `/php-quality-setup` |
| [`php/AGENTS.md`](php/AGENTS.md) | `AGENTS.md` | Every session in that project: one line pointing to the rules |

## Adding a stack

A global skill first reads `.agents/overlays/<job>.md` when it exists (`review`, `refactor`, `test`), so a stack adds
no skill description. To support another stack, add a folder like `php/` and an install script for it.

## In a project

Everything `install-php.sh` creates stays out of git: the paths go to the clone's `.git/info/exclude`. A `CLAUDE.md`
that already existed keeps its status. A project's own `AGENTS.md` is left untouched and the script prints the line to
add for agents other than Claude Code.

Add the project's own rules at the end of the installed `AGENTS.md`, under a heading starting with `## This project`:
updates keep those sections.

`install-php.sh` also migrates an install made by the former PHP-only `install.sh`. A skill that was not installed
from here is never replaced.

## License

MIT
