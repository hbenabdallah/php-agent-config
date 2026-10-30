# php-agent-config

Coding rules and skills for AI coding agents (Claude Code, Codex, Copilot, Cursor and others) working on PHP code.

The rules are technical, not architectural: types, classes, control flow, errors, comments, security, tests and
tooling, on top of PSR-1, PSR-4 and PER Coding Style 2.0. Layers, bounded contexts and folders are left to each
project, which knows its own. The project's instructions and tooling configuration always win, then the code already
there, then these rules.

They come from the conventions of several PHP projects in production and development (Symfony/DDD, Laravel, a static
analysis tool, a legacy PHP 4 code base), kept where they agreed, and from the review comments those projects
received.

## Contents

| Path | What |
|---|---|
| [`AGENTS.md`](AGENTS.md) | The rules. `AGENTS.md` is read by Codex, Copilot, Cursor and most agents. |
| [`CLAUDE.md`](CLAUDE.md) | `@AGENTS.md`: makes Claude Code read the same file. |
| [`skills/php-review`](skills/php-review/SKILL.md) | Review a diff, branch, PR or files against the rules; findings with file and line, verified. |
| [`skills/php-refactor`](skills/php-refactor/SKILL.md) | Behaviour-preserving refactoring in small verified steps (nested ternaries, long methods, arrays to value objects, types). |
| [`skills/php-test`](skills/php-test/SKILL.md) | Write tests the project's way: failing test first for a bug, one behaviour per test, fakes over mocks, deterministic. |
| [`skills/php-quality-setup`](skills/php-quality-setup/SKILL.md) | Add PHP CS Fixer, PHPStan max with strict rules, Rector and a `composer check` script; tested templates included. |
| [`install.sh`](install.sh) | Copies all of it into a project. |

Skills follow the [Agent Skills](https://agentskills.io) format (`SKILL.md` with a name and a description): the agent
loads one when the task matches its description.

## Install in a project

```sh
git clone https://github.com/hbenabdallah/php-agent-config.git
php-agent-config/install.sh path/to/project
```

It writes `AGENTS.md` (or `AGENTS.php.md` when the project already has its own `AGENTS.md`, which then should
reference it), adds `@AGENTS.md` to `CLAUDE.md` (to `.claude/CLAUDE.md` when the project keeps its instructions
there), and copies the skills to `.claude/skills/` (Claude Code) and `.agents/skills/` (Codex; Copilot reads both).

Everything it creates stays out of git: the paths are added to the clone's `.git/info/exclude`, which is never
committed (unlike `.gitignore`) and applies to that clone only (unlike a global excludes file, which would also hide
`AGENTS.md` in repositories meant to commit it). A `CLAUDE.md` that already existed keeps its status; a file already
tracked is reported, since ignoring it has no effect until `git rm --cached`. Codex, Copilot and Cursor read the
files from the working tree, so they work uncommitted too, on that machine.

Add the project's own rules at the end of `AGENTS.md`, under a heading starting with `## This project` (commands to
run the checks, architecture, naming, what not to touch). Run `install.sh` again to update: the shared rules and the
skills are replaced, the `## This project` sections are kept.

## License

MIT
