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

Every turn re-reads the whole conversation, so its cost grows with the context. Agent commands below are examples: use
your agent's equivalent.

### Context budget

- Treat about 40 % of the model's context window as the working limit, whatever the window size: past it, every turn
  re-reads all of it and costs that much again.
- Near the limit, stop at a clean point: write the handoff, then compact or ask the user for a fresh session
  (`/compact`, `/clear`, a new chat). Never keep going until compaction is forced.
- Never paste large outputs into the conversation: no full logs, whole files, full diffs or JSON dumps. Filter first
  (quiet or raw formats, changed files only, `grep`, counts, `| tail -n 40`); widen only for a failure that needs it.
- Search first, then read only the files or ranges the task needs. Never re-read a file or instructions already in
  context.

### One plan step per session

- When a plan file has numbered steps, do only the current step (the first whose "done when" is not met), then stop
  and report.
- The next step starts in a new session, from the plan file and the project notes only, never from memory of the
  previous conversation.
- Don't start the next step in the same session, even if the user says "go", unless they explicitly ask to continue
  there. Then compact first.

### Handoff

- At the end of each step, before reporting, write what the next session needs into the plan file or the project
  notes, not the chat: what was done, numbers measured, decisions taken and pending, files touched, the first action
  of the next step.
- The report to the user stays short and points to that note.

### Long-running work (benchmarks, test suites, builds, crawls)

- Run it in the background and wait for its completion notice (a background task, a job that notifies). Don't poll
  for progress: each poll re-reads the whole context.
- Without a notice mechanism, check rarely (no more than once every 10 to 20 minutes), with one short command whose
  output is a few lines.
- Before a run that spends the user's paid quota or API credits (an agent benchmark, a batch of LLM calls), state its
  estimated size (runs × tokens) and start with the smallest slice that answers the question.
- Stop the run on a quota or rate-limit error instead of recording failures.

### Cost-aware choices

- One command that does several things rather than several turns of tiny commands.
- Don't spawn subagents unless asked: each one starts cold and re-reads context.
- Suggest a cheaper model for mechanical work (reruns, captures, doc updates) when the agent can switch (`/model`).
  Never switch on your own.

### Plan file

Keep plans in a file (`PLAN.md`, or where the project keeps them), one section per step:

```markdown
# Plan: <goal>

## Step 1: <title>
- Goal: <what this step achieves>
- Done when: <a check the next session can run: a command, a number, a file>
- Handoff: <written at the end of the step: done, numbers, decisions taken and pending, files touched, next action>
```
