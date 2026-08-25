# cswax agent guidance

This repository owns delivery and maintenance of the operator's claude-swap
fork — the `cswap` agentusage observes and the machine launches Claude
accounts through. Read `CONTEXT.md`, `MAINTAIN.md`, and `SCRATCHPAD.md` before
changing the fork or its install.

## Ownership

- `MAINTAIN.md` is the project specification and the whole of what the shared
  `maintain` skill knows about claude-swap: purpose, upstream and our stance
  toward it, the branch model, the feature inventory that must remain true,
  the gate, the consumer, and the notification. Its section headings are fixed
  — the skill reads them by name — so add to a section rather than renaming
  one.
- `/maintain` is the shared `maintain` skill in `~/code/agentguidance`, the
  operating procedure for every fork workshop on this machine. claude-swap
  specific procedure belongs in `MAINTAIN.md`, never in a copy of the skill
  here.
- Every behavior the fork carries is reversed into `MAINTAIN.md` § Features by
  the same change that builds it, in the same commit. The entry is part of the
  work, never a follow-up: a carried feature the inventory does not name is
  unfinished, because the next cycle reconciles only what that section states.
- `SCRATCHPAD.md` is current maintenance state, not a second specification or
  an unbounded transcript.
- `scripts/reconcile-branches.sh` is the thin entrypoint to the skill's shared
  namespace script: it declares the branch model `MAINTAIN.md` states — carry
  heads under `carry/`, open-request heads validated, explicit `DELETEME/`
  markers — and nothing else. Reconciliation leaves all undeclared refs
  unchanged; the mechanics live and are tested in agentguidance.
- `scripts/install.sh` is the consumer step: it binds the checkout to a
  published `integration` commit and installs it with `uv tool install`. It
  never rebases, publishes, or touches a pull request.

The checkout being maintained is `~/src/claude-swap`, cloned with
`--origin fork`: `fork` is `possibilities/claude-swap` and `origin` is
`realiti4/claude-swap`. That is the reverse of the usual reading and is worth
rechecking before any push.

## The two open requests

The fork's reason to exist is that
[#166](https://github.com/realiti4/claude-swap/pull/166) and
[#169](https://github.com/realiti4/claude-swap/pull/169) have sat unreviewed
since 2026-07-23. They are kept mergeable and otherwise left alone. Do not
refresh, rebase, comment on, label, or close them as part of maintenance — a
force-push into a review context we did not open is worse than a stale branch,
and tending open requests is `watch-requests`' loop, not this repository's.
Report movement; act on it only at the next cycle, by reading upstream's code.

## Working topology

Work directly on `main` in this repository. Outside this repository, create a
dedicated worktree, commit the finished change, and remove the worktree after
it lands. Never do feature work in the bound claude-swap checkout, never
force-update `integration` in place, and never push onto a branch a pull
request is open on.

Each carried feature is a `carry/<feature>` head based on current upstream, and
`integration` is those heads composed in the dependency order `MAINTAIN.md`
declares. A feature is repaired on its own head; a landed one is dropped by
removing its head from the composition. An offer to upstream is written fresh
from current `origin/main`, shaped as upstream would write it — not a carry
head pushed across.

Maintenance owns only `main`, `integration`, and current `carry/*` heads.
Creating, moving, or removing a `DELETEME/<original>` ref requires an explicit
human decision naming that branch; age, ownership, request state, and
namespace are never deletion intent.

## Validation

Run:

```sh
tests/validate.sh
```

Fork work follows `MAINTAIN.md`'s gate in full — all three of upstream's CI
jobs, including the macOS keychain contract suite, plus the fork's own CI green
on the exact candidate commit. Installing is `scripts/install.sh`, never a hand
`uv tool install`.

Finished work lands on `main` and is pushed.
