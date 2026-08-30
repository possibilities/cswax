# Maintenance scratchpad

This is current state for `/maintain`. The skill updates or removes stale
entries on every maintenance cycle and appends one compact history entry.

## Baseline

- Last completed maintenance: **2026-08-29**.
- Delivered upstream base: `2213700b5a1331f50939ce1f41b531e674d612a6`
  (`realiti4/claude-swap:main`, "test cleanup").
- Audited-upstream frontier: `2213700b5a1331f50939ce1f41b531e674d612a6`,
  completed **2026-08-29**. The aggregate audit range was
  `3c3f2b887a3d46a6457628ac3bf0074c2d975c23..2213700b5a1331f50939ce1f41b531e674d612a6`
  (2 commits). Upstream dispositions: **0 retired, 0 upstream-driven repairs,
  5 unchanged**. `af6a5b2` added the notable `cswap add` owner/rotation guard
  from #216; `2213700` was test cleanup. Neither replaced or altered a carried
  contract.
- Published integration: `f7385b7c5e19d0024d23e37b2634cf6a6b9aa01b`,
  14 commits above the delivered base.
- Installed: `scripts/install.sh --install --sha f7385b7…` bound
  `~/src/claude-swap` to the published commit and installed `cswap 0.26.0b1`.
- Local gate on exact candidate `f7385b7`: `uv sync --locked`; full suite,
  **2200 passed, 3 skipped**; macOS Keychain suites, **44 passed, 3 skipped**.
- Real-profile checks from that candidate: `cswap ls --json` emitted
  `subscriptionType: "max"` and `rateLimitMultiplier: 20` for both accounts;
  `cswap recover 99 --json` returned the PII-free `RecoveryError` envelope.
  No live recovery ran because no real token was expired.
- External proof: fork CI run
  [33286771567](https://github.com/possibilities/claude-swap/actions/runs/33286771567)
  completed successfully on exact SHA `f7385b7`; `test`, `test-windows`, and
  `macos-keychain` were all green.
- The previous cycle's delayed run
  [32892437789](https://github.com/possibilities/claude-swap/actions/runs/32892437789)
  also eventually completed with all three jobs green on `693a4f6`, closing
  that cycle's hosted-capacity exception retroactively.

## Carry heads

The five declared heads form one chain on the delivered upstream base in the
dependency order `MAINTAIN.md` declares. Each head owns only the commits above
its predecessor; every head is an ancestor of Integration.

| Carry head | Owns | Exact tip | Above upstream |
| --- | --- | --- | --- |
| `carry/account-capacity-metadata` | `0caf831`, `6849550` | `68495506df0ffdf8eb626a1b47f3be2a3e4c7eb5` | 2 |
| `carry/recover-expired-token` | `c8286f4`, `ac01cdc`, `95f560b`, `9291d6d`, `2a71a2b`, `480a208` | `480a208fdff28f3eaf051fa1b9a9332550496b43` | 8 |
| `carry/deferred-shared-history-resume` | `9bf30c2` | `9bf30c2629f1787249cbc8a4ee8c5e58fbce765e` | 9 |
| `carry/already-routed-sentinel` | `cece5b0` | `cece5b0f3092399c738e736610045069d6e8cd8e` | 10 |
| `carry/fork-packaging` | `e25ecf4`, `9b65943`, `bd792e9`, `f7385b7` | `f7385b7c5e19d0024d23e37b2634cf6a6b9aa01b` | 14 |

`carry/fork-packaging` is the Integration tip.

**Account capacity metadata** — offered as #169 at exact historical head
`0a5788d9a9a0ebb932592ac3ce520be6470e1d24`. Its two commits remained
patch-equivalent across the upstream replay. Verified by the full gate and the
real `cswap ls --json` capacity fields above. Retires only on the replacement
condition in `MAINTAIN.md` § Features.

**Owner-held expired token recovery** — offered as #166 at exact historical
head `b23a3a3caf11d246f75a7b4044d33fd2220032c3`. The five prior commits
remained patch-equivalent; `480a208` repairs the idle-session/dead-backup edge.
A fresh session challenges quarantine with its exact strict credential under a
claim, and only a successful fetch followed by a matching identity re-read
clears the strike. Keychain loss, fetch failure, unreadable identity, or `/login`
drift preserves it. Adversarial reproductions covered each case plus concurrent
and late claim writers; 630 switcher/store/Keychain-contract tests passed with
3 skips before the full gate. Retires only on all conditions in the inventory.

**Stranded shared-history resume refusal** — not offered. `9bf30c2` is
patch-equivalent to the previous carry. The full gate verifies it; upstream at
`2213700` has no replacement. Retires when upstream refuses the same resume.

**Already-routed sentinel** — never offerable. `cece5b0` is patch-equivalent to
the previous carry and depends on the recovery files below it. The full gate
verifies session and recovery-canary launch routing. It retires only if the
balancing shims stop existing.

**Fork packaging** — never offerable. Its three previous commits remained
patch-equivalent. `f7385b7` corrects the public README so consumers install and
source-build from `integration`, not mirrored `main`. The full local and hosted
three-job gates verify the exact tip. It retires with the fork.

## Fork namespace

- Final reconciliation completed `--check`, atomic `--apply`, `--check`.
  Fork `main` is the exact upstream mirror at `2213700`; `integration` and all
  five `carry/*` heads equal the tips above.
- Open-request heads were validated and left untouched:
  `feat/account-capacity-metadata` at `0a5788d` (#169) and
  `feat/recover-expired-token` at `b23a3a3` (#166).
- `ci/candidate-20260825-b` remains at `693a4f6`; its once-delayed proof is now
  green. It is undeclared and unchanged pending an explicit disposition.
- `ci/candidate-20260829-e65143e` remains at `e65143e`. Run
  [33285585615](https://github.com/possibilities/claude-swap/actions/runs/33285585615)
  was cancelled after adversarial review found the candidate invalid;
  `integration` was never moved to it.
- `ci/candidate-20260829-f7385b7` remains at the proved final candidate
  `f7385b7`. It is undeclared and unchanged pending an explicit disposition.
- The explicit marker `DELETEME/ci/candidate-20260825` remains at `693a4f6`.
  Maintenance did not create, move, or remove it.
- Other undeclared heads were reported and left unchanged:
  `fix/deferred-shared-history-resume` (`9614868`),
  `fix/usage-fetch-lease` (`33592fd`), `fix/watch-external-refresh`
  (`34a0ba2`), `fix/effective-token-status` (`3314d75`),
  `fix/poll-exhausted-accounts` (`e6dd4a7`), and
  `feat/display-last-good-usage` (`2d5614c`).

## Offers

- [#169](https://github.com/realiti4/claude-swap/pull/169),
  `feat/account-capacity-metadata`: open, mergeable, unreviewed, exact head
  `0a5788d`; no movement in the audited interval.
- [#166](https://github.com/realiti4/claude-swap/pull/166),
  `feat/recover-expired-token`: open, mergeable, unreviewed, exact head
  `b23a3a3`; no movement in the audited interval.

Neither request was refreshed, rebased, commented on, labeled, or otherwise
mutated. `watch-requests` owns their loop.

## Notes that can change a later decision

- **Upstream capability #216.** `af6a5b2` makes `cswap add` refuse a captured
  credential whose owner is not the requested account and guards rotation
  under ownership checks. It is useful upstream hardening, but not a complete
  replacement for any carried feature.
- **An upstream macOS test defect we fix and deliberately do not offer.** Bare
  upstream's move/swap unreadable-source probes chmod a `.creds-*.enc` that the
  healthy Keychain path never writes. Packaging commit `bd792e9` pins those
  probes to file storage. The operator decided on 2026-08-25 not to add a third
  offer while #166 and #169 remain unreviewed; revisit only if upstream starts
  reviewing again. The same commit's `tests/test_settings.py` chmod adjustment
  is umask-defensive, not a currently failing upstream test.
- **The gate trigger is structurally fragile.** Mirrored `main` does not carry
  `workflow_dispatch`, although dispatch still succeeded for both candidates
  this cycle. `MAINTAIN.md` § Gate records the fork-internal pull request as the
  reliable fallback.
- The checkout was cloned `--origin fork`: `fork` is ours and `origin` is
  upstream, the reverse of the usual reading.
- The fork's CI is itself carried by `carry/fork-packaging`; repairing packaging
  edits part of the proof mechanism.
- `~/src/claude-swap-integration-build.gdKtP8` remains a clean, unused,
  pre-workshop worktree on `integrate/deferred-shared-history-resume` at
  `6731a8f`. The local `agent/public-fork-docs` branch at `3b76d79` is likewise
  outside maintenance ownership.
- agentusage consumes the fork's per-route `account_capacity` JSON contract;
  its consumer tests remain relevant for any later capacity change.

## History

- **2026-08-25** — Workshop created and first cycle completed. Mirrored `main`
  at `3c3f2b8`, decomposed the byte-identical Integration tree into five carry
  heads, ran the complete local gate, published and installed `693a4f6`, and
  recorded the temporary hosted-capacity exception plus the decision not to
  offer the upstream macOS test fix.
- **2026-08-29** — Audited
  `3c3f2b887a3d46a6457628ac3bf0074c2d975c23..2213700b5a1331f50939ce1f41b531e674d612a6`
  (2 commits). Notable: #216's add-owner/rotation guard. Upstream dispositions:
  0 retired, 0 repaired, 5 unchanged. Replayed all carries, repaired the
  fresh-session/dead-backup proof so exact strict bytes and post-fetch identity
  fence every quarantine clear, and corrected README installs to
  `integration`. The first candidate `e65143e` and run `33285585615` were
  cancelled after review found it unsafe. Candidate `f7385b7` passed the local
  gate, real-profile checks, adversarial review, and all three hosted jobs in
  run `33286771567`; published under the original lease on `693a4f6`, installed,
  and reconciled all declared refs. The prior delayed proof on `693a4f6` also
  finished green, closing the earlier exception.
