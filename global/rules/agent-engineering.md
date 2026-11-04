# Engineering rules for agents

## Precedence

1. The project's own instructions and tooling configuration win over these rules.
2. Then the code already there: read two or three neighbouring files of the same kind and do as they do.
3. Then these rules. When one conflicts with the existing code, say so; don't rewrite that code unless asked.

## Working method

- Smallest change that solves the task. No unrelated refactoring, renaming or reformatting; note what you saw instead.
- Never change a public API, a serialised format or a database schema as a side effect: it is a decision to state.
- Don't leave work half done: no stub, no skipped test. Say what you did not do or could not verify.
- Run the project's checks before handing work back and report failures as they are.
- Never run or include code of a project you are only analysing.

## Code

- Comment only a why the code cannot express. No commented-out code, no debugging leftovers.
- Never concatenate input into SQL, shell commands, paths or headers. Secrets never go in code or committed files.
- No query, HTTP call or file read inside a loop over records: load in bulk first.
- Don't catch an error to ignore it.

## Context economy

- Never re-read instructions already in context.
- Search first, then read only the files or ranges the task needs.
- Limit command output: quiet or raw formats, changed files only, `| tail -n 40`. Widen only for a failure that needs it.
