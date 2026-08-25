# Maintenance scratchpad

This is current state for `/maintain`. The skill updates or removes stale
entries on every maintenance cycle and appends one compact history entry.

## Baseline

- Last completed maintenance: **2026-08-25**, the first cycle. Upstream had not
  moved since the workshop was seeded, so the cycle's work was structural: the
  mirror, the decomposition into carry heads, and the first full gate.
- Upstream base: `3c3f2b887a3d46a6457628ac3bf0074c2d975c23`
  (`realiti4/claude-swap:main`, "Merge pull request #267 from
  codeslake/fix/test-isolated-home-leak") — unchanged since the workshop was
  created.
- Published integration: `693a4f64ab6f8c539e66aede1117785f43f7d3b2`, 12 commits
  above the base. Its tree is byte-identical to the superseded
  `a789afc6a8a7a42c75289cda02fb0a1b2cea1f04`: the decomposition changed the
  history's shape, not one line of the delivered code, which is the evidence
  that it was faithful. The two commits that disappeared were the duplicate
  `9614868` and the empty merge `a789afc` itself.
- Installed: `scripts/install.sh --install --sha 693a4f6…` bound the checkout
  and ran `uv tool install --force`.
- Gate as last run: all three of `MAINTAIN.md` § Gate's **local** commands,
  green on the exact candidate. `uv run pytest` — 2160 passed, 3 skipped. The macOS keychain
  contract suite — 44 passed, 3 skipped, real-`security` tests included. **This
  is the first time the keychain job has ever run against a candidate here**;
  the installer-driven path it replaced ran only upstream's Ubuntu job.
- External proof: **not obtained — an exception was taken.** On the exact
  candidate, `test` and `test-windows` were green (run 32875084489), and
  `macos-keychain` never started: over four hours, across three independent
  runs, GitHub's hosted macOS pool scheduled it zero times. Historically that
  job started in 2-4s and finished in 11-16s, so this was capacity, not the
  candidate; GitHub had posted and resolved "Actions delays in starting runs"
  the previous day. The operator accepted the green local gate as proof and
  authorized publication. `MAINTAIN.md` § Gate records the exception and its
  limits. **The gate is still all three jobs.**
- `ci/candidate-20260825-b` at `693a4f6` is still live and still queued. It is
  the outstanding attempt at the missing hosted proof for the published commit.
  If it ever goes green the exception above closes retroactively; record that
  and drop the branch. If a later cycle publishes past it, it is spent.

## Carry heads

All five exist now. They are one chain on current upstream in the dependency
order `MAINTAIN.md` declares; each head is the tip of its own segment, so a
head contains the heads before it and owns only the commits above its
predecessor. Those owned commits are the feature.

| Carry head | Owns | Tip | Above upstream |
| --- | --- | --- | --- |
| `carry/account-capacity-metadata` | `a7970a3`, `845a6df` | `845a6df` | 2 |
| `carry/recover-expired-token` | `c8a92e8`, `98c5ed1`, `12e4654`, `cb12e14`, `a89d08d` | `a89d08d` | 7 |
| `carry/deferred-shared-history-resume` | `4ce6917` | `4ce6917` | 8 |
| `carry/already-routed-sentinel` | `8c28b07` | `8c28b07` | 9 |
| `carry/fork-packaging` | `f339052`, `74d6b38`, `693a4f6` | `693a4f6` | 12 |

`carry/fork-packaging`'s tip is the integration candidate itself.

**Account capacity metadata** — offered as #169 (`0a5788d`, open, unreviewed).
Verified this cycle by `cswap ls --json` from the candidate build: both real
accounts carry `subscriptionType: "max"` and `rateLimitMultiplier: 20`, the
shape agentusage reads as `account_capacity`. Retires when upstream emits both
fields with these types and the same omission behavior.

**Owner-held expired token recovery** — offered as #166 (`b23a3a3`, open,
unreviewed). Verified by the keychain contract suite plus `cswap recover 99
--json` from the candidate build, which returned the PII-free envelope
(`schemaVersion: 1`, `error.type: "RecoveryError"`). A live recovery was not
run: no account's token was expired, and the command mutates. Retires only on
all three conditions in the inventory entry, read in upstream's code.

**Stranded shared-history resume refusal** — not offered. Applies cleanly to
bare upstream on its own; it is third in the order only because it is repaired
after the two offered heads. Retires when upstream refuses the same resume.

**Already-routed sentinel** — never offerable. Cannot sit on bare upstream:
cherry-picking it there conflicts modify/delete on `src/claude_swap/recovery.py`
and `tests/test_recovery.py`, which `carry/recover-expired-token` creates. That
is the concrete reason the chain construction is the only one that satisfies
both the dependency order and reconciliation's ancestry requirement.

**Fork packaging** — never offerable. Its third commit (`693a4f6`, "fix rebased
fork test contracts") was provisionally assigned here by the seeded scratchpad,
and this cycle settled it: **all four hunks stay in packaging**, because none of
them serves a carried feature. Every one adjusts an upstream fixture that is
already upstream's own — `_KeychainStore` and the autouse `block_real_keychain`
guard, and `get_default_claude_config_home`, which upstream now provides in
`paths.py`. See the upstream-defect note below for what two of them actually
fix.

## Fork namespace

- `main` is now an exact mirror at `3c3f2b8`, locally and on the fork. It was
  `935780b` — 10 commits of an old integration-style history — and
  `reconcile-branches.sh --check` refused on it, as the seeded scratchpad
  predicted. Before resetting, all 10 were compared against `integration` by
  patch-id: 9 were identical, and the tenth ("feat(auth): recover owner-held
  expired tokens") was **older** on `main` — `integration`'s version reads
  `CLAUDE_CODE_KEYCHAIN_SERVICE` explicitly instead of going through
  `_read_active_oauth_keychain`, and drops a `paths.py` helper upstream now
  ships. Nothing was lost. The reset was a one-time exact-leased push; the
  shared script cannot repair a diverged fork `main`, it only refuses.
- `ci/candidate-20260825` at `693a4f6` — the temporary branch pushed to obtain
  external proof. The operator decided on 2026-08-25 to get rid of it once the
  gate was green; it is now `DELETEME/ci/candidate-20260825`, and the original
  is gone. It could not be removed earlier: `macos-keychain` was still queued
  against that ref, and deleting it would have killed a live proof attempt.
  **A future cycle's proof branch has the same constraint** — it is disposable
  only once its run has completed or been abandoned.
- `ci/candidate-20260825-b` at `693a4f6` — a second proof branch, pushed to get
  an independent queue slot without cancelling the first run. Deliberately kept
  alive; see the baseline note. The fork-internal pull request opened for a
  third slot was possibilities/claude-swap#4, closed the same day.
- `feat/account-capacity-metadata` (`0a5788d`) and `feat/recover-expired-token`
  (`b23a3a3`) — the two open pull-request heads. Validated at their exact SHAs
  this cycle, never moved.
- Undeclared, unchanged, reported: `fix/deferred-shared-history-resume`
  (`9614868`), `fix/usage-fetch-lease` (`33592fd`), `fix/watch-external-refresh`
  (`34a0ba2`), `fix/effective-token-status` (`3314d75`),
  `fix/poll-exhausted-accounts` (`e6dd4a7`), `feat/display-last-good-usage`
  (`2d5614c`). The last five carry behavior that is upstream's now.
- One marker exists: `DELETEME/ci/candidate-20260825` at `693a4f6`, recording
  the operator's 2026-08-25 decision to discard that spent proof branch.

## Offers

- [#169](https://github.com/realiti4/claude-swap/pull/169)
  `feat/account-capacity-metadata`, opened 2026-07-23, `MERGEABLE`, no review
  decision, last touched 2026-08-13 by our own rebase. No movement this cycle.
- [#166](https://github.com/realiti4/claude-swap/pull/166)
  `feat/recover-expired-token`, opened 2026-07-23, `MERGEABLE`, no review
  decision, same date. No movement this cycle.

Neither is refreshed, nudged, or closed by a maintenance cycle.
`watch-requests` owns them.

## Notes that can change a later decision

- **An upstream defect we fix and deliberately do not offer.** Bare
  `realiti4/claude-swap:main` fails two tests on macOS:
  `tests/test_move_accounts.py::TestMoveUnreadableSourceIsNotAbsent` and
  `tests/test_swap_accounts.py::TestSwapUnreadableSourceIsNotAbsent`, both
  `test_unreadable_..._aborts_...`. They chmod a `.creds-*.enc` file to prove a
  POSIX-readability abort, but on Darwin the healthy autouse Keychain fake means
  no `.enc` is ever written, so `Path.chmod` raises `FileNotFoundError`.
  Upstream's CI cannot see this: its macOS job runs only the two keychain
  suites, and the full-suite jobs are Ubuntu and Windows. Two hunks of
  `693a4f6` fix it in four lines each by pinning `switcher.platform =
  Platform.LINUX`. It would make a clean third offer; the operator decided on
  2026-08-25 not to make one, and `MAINTAIN.md` § Features now carries the
  reason. Do not reopen this without a new decision — the trigger to revisit is
  upstream reviewing #166 or #169.
- The same commit's `tests/test_settings.py` hunk (`mkdir(mode=0o755)` →
  `mkdir(); chmod(0o755)`) fixes nothing currently failing — that file passes on
  bare upstream here. It is umask-defensive. Do not fold it into any offer.
- **The gate's trigger is structurally fragile.** Resetting `main` to the exact
  upstream mirror removed `workflow_dispatch` from the fork's default branch,
  which is what GitHub requires to offer it. This cycle's dispatch succeeded on
  a registration left over from before the reset. `MAINTAIN.md` § Gate now
  documents the fork-internal pull request as the reliable path; expect to need
  it next cycle.
- The checkout was cloned `--origin fork`. `fork` is ours, `origin` is upstream
  — the reverse of the usual reading, and worth rechecking before any push.
- The fork's CI is a carried file (`carry/fork-packaging`), so a cycle that
  repairs packaging is editing the thing that proves the candidate.
- `~/src/claude-swap-integration-build.gdKtP8` is still there, on
  `integrate/deferred-shared-history-resume` at `6731a8f` — a superseded merge
  attempt, clean, unused, not on the fork, and predating this workshop. Still
  the human's call. The local branch `agent/public-fork-docs` (`3b76d79`) is in
  the same category.
- agentusage pins provider contracts to this fork's JSON shape; its
  `test/claude-observe.test.ts` asserts `account_capacity` per route. A
  capacity-metadata change that passes claude-swap's own suite can still break
  the consumer.

## History

- **2026-08-25** — Workshop created. `MAINTAIN.md` seeded from the fork as it
  stands, agentusage's `rebase_fork_onto_upstream` removed so no unattended
  converge can rewrite or publish the fork, and installation moved to
  `scripts/install.sh`.
- **2026-08-25** — First cycle. Upstream unmoved at `3c3f2b8`. Mirrored `main`
  (was 10 commits diverged, verified lossless by patch-id first). Decomposed
  `integration` into the five declared carry heads, dropping a duplicated commit
  and an empty merge and leaving the tree byte-identical. Ran the full gate
  including the macOS keychain job for the first time — green. Published
  `693a4f6` under an exact lease on `a789afc` and installed it. Corrected
  `MAINTAIN.md` § Branch model, whose stated construction (every head on bare
  upstream) is unsatisfiable alongside the ancestry requirement, and § Gate,
  whose external proof had lost its trigger to the mirror requirement. Found
  two upstream macOS test failures our packaging head already fixes; the
  operator decided not to offer them upstream, and not to keep the spent proof
  branch. The hosted `macos-keychain` job never got a runner in four hours; the
  operator accepted the green local gate instead, and that exception is
  recorded in `MAINTAIN.md` § Gate. All recorded above.
