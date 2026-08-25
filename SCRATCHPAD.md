# Maintenance scratchpad

This is current state for `/maintain`. The skill updates or removes stale
entries on every maintenance cycle and appends one compact history entry.

## Baseline

- Last completed maintenance: **none**. This is the seeded state, written when
  the workshop was created on 2026-08-25. The fork was maintained before that
  by agentusage's installer, which rebased and force-pushed `integration` on
  every machine converge; that path has been removed.
- Upstream base: `3c3f2b887a3d46a6457628ac3bf0074c2d975c23`
  (`realiti4/claude-swap:main`, "Merge pull request #267 from
  codeslake/fix/test-isolated-home-leak").
- Published integration: `a789afc6a8a7a42c75289cda02fb0a1b2cea1f04`, 14
  commits above the base, which the base is an ancestor of — the carried set
  is currently on current upstream.
- Installed: `uv tool install` from the bound checkout at that commit.
- Gate as last run: unknown. The installer's gate was
  `uv sync --locked && uv run pytest` — upstream's Ubuntu job only. The macOS
  keychain contract job `MAINTAIN.md` now requires has never been run against
  a candidate here.

## Carry heads

**None exist yet.** `integration` is still the linear history the installer
built, and the first cycle's work is to decompose it into the heads
`MAINTAIN.md` § Features names. Until then, reconciliation reports every carry
head as absent, which is correct: absence is work.

The decomposition, from the current `integration`, in dependency order:

| Carry head | Commits on `integration` today |
| --- | --- |
| `carry/account-capacity-metadata` | `0628256`, `00e3fb5` |
| `carry/recover-expired-token` | `5356926`, `f65aa97`, `e10cfbb`, `443fbe6`, `ef518f6` |
| `carry/deferred-shared-history-resume` | `6ce6c05` |
| `carry/already-routed-sentinel` | `442be83` |
| `carry/fork-packaging` | `66f3b58`, `4c870ce`, `8ab86e7` |

Two commits do not appear above and are the reason the decomposition is worth
doing rather than deferring:

- `9614868` is the same behavior as `6ce6c05`, applied twice. It is the head
  of the fork branch `fix/deferred-shared-history-resume`.
- `a789afc`, the current tip, is an **empty merge commit** — it merged
  `fix/deferred-shared-history-resume` into `integration` after `6ce6c05` had
  already applied that behavior, so it changed no files. The published tip of
  the branch the machine installs is a merge that carries nothing.

`8ab86e7` ("fix rebased fork test contracts") is assigned to
`carry/fork-packaging` provisionally. It touches `tests/conftest.py`,
`tests/test_move_accounts.py`, `tests/test_settings.py`, and
`tests/test_swap_accounts.py`; the first cycle should determine which carried
feature each hunk actually serves and move it onto that head, leaving only
genuinely fork-shaped test contracts in packaging.

## Fork namespace

Beyond `integration`, the fork holds:

- `main` at `935780b8b4c7f3eeaf58fa44c2e7eebfbc24907c` — **not a mirror**. It
  is 10 commits ahead of upstream and 9 behind: an old integration-style
  history sitting on the branch `MAINTAIN.md` requires to be an exact mirror
  of `realiti4/claude-swap:main`. The bound checkout's local `main` is the same
  commit and equally diverged. `scripts/reconcile-branches.sh --check` refuses
  on exactly this — "local main has commits outside origin/main" — and that
  refusal is the correct first thing the workshop says. The first cycle resets
  both to upstream; every commit on them is already published on `integration`
  or on a fork branch, so nothing is lost. It is a declared ref, so
  reconciliation owns it; nothing else on the fork reads it.
- `feat/account-capacity-metadata` at `0a5788d` and
  `feat/recover-expired-token` at `b23a3a3` — the two open pull-request heads.
  Validated, never moved.
- `fix/deferred-shared-history-resume` at `9614868`, and five branches from
  the merged July requests: `fix/usage-fetch-lease` (`33592fd`),
  `fix/watch-external-refresh` (`34a0ba2`), `fix/effective-token-status`
  (`3314d75`), `fix/poll-exhausted-accounts` (`e6dd4a7`),
  `feat/display-last-good-usage` (`2d5614c`). All undeclared: reported every
  cycle, never touched without an explicit human decision. Their behavior is
  upstream's now, so quarantining them would be reasonable — but that is the
  human's call to make by name.

## Offers

- [#169](https://github.com/realiti4/claude-swap/pull/169)
  `feat/account-capacity-metadata`, opened 2026-07-23, `MERGEABLE`, no review
  decision, last touched 2026-08-13 by our own rebase.
- [#166](https://github.com/realiti4/claude-swap/pull/166)
  `feat/recover-expired-token`, opened 2026-07-23, `MERGEABLE`, no review
  decision, same date.

Neither is refreshed, nudged, or closed by a maintenance cycle. `watch-requests`
owns them. Five earlier requests (#160, #170, #172, #173, #182) merged in July
2026 and are not carried.

## Notes that can change a later decision

- The checkout was cloned `--origin fork`. `fork` is ours, `origin` is
  upstream — the reverse of the usual reading, and worth rechecking before any
  push.
- The fork's CI (`.github/workflows/ci.yml` as carried by `66f3b58`) is the
  external proof the gate requires. It is a carried file: a cycle that repairs
  `carry/fork-packaging` is editing the thing that proves the candidate.
- `~/src/claude-swap-integration-build.gdKtP8` is a scratch worktree left
  behind by an earlier build, on the local branch
  `integrate/deferred-shared-history-resume` at `6731a8f` — a superseded
  attempt at the same merge `a789afc` published, not an ancestor of
  `integration`, and not on the fork. Clean and unused as of 2026-08-25. It
  predates this workshop, so the first cycle reports it rather than removing
  it in passing; disposing of it, and of its branch, is the human's call.
- agentusage pins provider contracts to this fork's JSON shape; its
  `test/claude-observe.test.ts` asserts `account_capacity` per route. A
  capacity-metadata change that passes claude-swap's own suite can still
  break the consumer.

## History

- **2026-08-25** — Workshop created. `MAINTAIN.md` seeded from the fork as it
  stands, agentusage's `rebase_fork_onto_upstream` removed so no unattended
  converge can rewrite or publish the fork, and installation moved to
  `scripts/install.sh`. No cycle run yet: no carry heads, `main` not yet a
  mirror, gate not yet run with the keychain job.
  `scripts/reconcile-branches.sh --check` refuses on the diverged `main`,
  which is the first cycle's opening work.
