# claude-swap fork maintenance

This repository delivers and maintains our fork of
[`realiti4/claude-swap`](https://github.com/realiti4/claude-swap): the `cswap`
account manager agentusage observes and the machine launches Claude accounts
through. It owns the behavior agentusage needs independently of upstream
review while continuously rebuilding that behavior on current upstream.
`/maintain` — the shared `maintain` skill — runs a maintenance cycle from this
file; this file is the whole of what that skill knows about claude-swap.

## Purpose

Keep a published `integration` branch of claude-swap that carries every feature
below, rebuilt on current upstream every cycle, and installed by agentusage
through this repository's own installer.

The fork is narrow and, for two of its features, involuntary. Upstream merged
five of our seven pull requests within days in July 2026 and has not responded
to the remaining two since. The fork exists so that agentusage does not wait on
that: it carries the capacity metadata and expired-token recovery those two
requests offer, plus a small number of behaviors that were never offerable, and
retires each the day upstream carries it.

What the fork is not: a place to develop `cswap` features for their own sake, a
long-term divergence, or a second opinion about the project's direction. Every
carried feature has a retirement condition, and a feature nobody would offer
upstream needs a reason in its inventory entry for why not.

## Upstream

- Bound checkout: `~/src/claude-swap`. `fork` is `possibilities/claude-swap`;
  `origin` is `realiti4/claude-swap`. The clone was made with
  `--origin fork`, so upstream is `origin` and the fork is `fork` — the reverse
  of the usual reading, and the reason both remotes are named here rather than
  inferred.
- claude-swap has no `AGENTS.md`. The consumer's language is agentusage's
  (`~/code/agentusage/AGENTS.md` and `CONTEXT.md`) — **Provider**, **Route**,
  **Slot** — and is read before touching the fork, because the JSON these
  features shape is what agentusage parses.
- Contribution conventions: no `CONTRIBUTING.md`, issue template, or CLA.
  Hosted CI runs on pull requests — three jobs, Ubuntu and macOS suites plus a
  macOS keychain contract job. Direct pull requests are normal, and the
  maintainer merges them as pull requests rather than rewriting them onto
  `main`, so GitHub's merged state is meaningful here in a way it is not for
  every upstream.
- What we offer: whole features, one request each, written as upstream would
  write them. Two are open and have been since 2026-07-23:
  - [#169](https://github.com/realiti4/claude-swap/pull/169)
    `feat/account-capacity-metadata` — `MERGEABLE`, no review, last touched
    2026-08-13 by our own rebase.
  - [#166](https://github.com/realiti4/claude-swap/pull/166)
    `feat/recover-expired-token` — `MERGEABLE`, no review, same date.

  Five earlier requests merged in July 2026:
  [#160](https://github.com/realiti4/claude-swap/pull/160),
  [#170](https://github.com/realiti4/claude-swap/pull/170),
  [#172](https://github.com/realiti4/claude-swap/pull/172),
  [#173](https://github.com/realiti4/claude-swap/pull/173), and
  [#182](https://github.com/realiti4/claude-swap/pull/182). Their behavior is
  upstream's now and is not carried.
- **The stance toward the two open requests.** They are kept mergeable and
  otherwise left alone. A maintainer who has not looked in a month is not
  waiting for a nudge, and a rebase force-pushed into a review context we did
  not open is worse than a stale branch. The cycle therefore does not refresh,
  comment on, label, close, or reopen them; it validates their exact heads and
  reports what changed. Tending open requests belongs to `watch-requests`,
  which already owns that loop for every upstream on this machine — this
  workshop must not grow a second one.
- What the cycle *does* report: a commit upstream that implements or collides
  with a carried feature, a review or comment appearing on either request after
  months of silence, either request closing, and a release that carries a
  carried behavior. All four are `## Notify` material and belong in the
  scratchpad's history whether or not they change the cycle's work.
- "Landed" means the behavior is on `realiti4/claude-swap:main`, decided by
  reading that code and exercising its path. A merged pull request is strong
  evidence here — the maintainer merges rather than rewrites — but it is still
  the code that decides, and a merge that arrives alongside a refactor may
  land less than the request offered.

## Branch model

- Mirror branch: `main`, an exact mirror of `realiti4/claude-swap:main` locally
  and on the fork. Never an integration base with downstream-only commits.
- Integration branch: `integration`, every carried feature composed together.
  It is the only ref the installer builds and binds, and it is nobody's review
  context.
- Composition: **carry heads**. Each carried feature owns a `carry/<feature>`
  branch, and `integration` is those heads composed in dependency order in a
  scratch worktree each cycle. This is the model because the two features that
  matter are offered upstream whole and independently: when #169 lands,
  `carry/account-capacity-metadata` is dropped by rebuilding the composition
  without its commits, which does not disturb the recovery work, and vice
  versa. A linear stack would make each retirement a rebase of everything
  above it.
- Dependency order, which is not alphabetical and is part of the model:
  `carry/account-capacity-metadata`, `carry/recover-expired-token`,
  `carry/deferred-shared-history-resume`, `carry/already-routed-sentinel`,
  `carry/fork-packaging`. The last two touch files the earlier heads create,
  so they compose after them and are repaired against them.
- How the heads are built, which the ancestry requirement decides. Every carry
  head must be an ancestor of the published `integration`; reconciliation
  refuses a head that is not, and `carry/already-routed-sentinel` and
  `carry/fork-packaging` cannot sit on bare upstream at all, because the files
  they patch do not exist until the earlier heads create them. So the
  composition is built once, as one chain on current upstream in the
  dependency order above, and each `carry/<feature>` head is the tip of its own
  segment of that chain: the first head sits on upstream, each later head on
  the head before it, and `carry/fork-packaging` is the integration candidate
  itself. A head therefore *contains* the heads it depends on and *owns* only
  the commits above its predecessor — those commits, not the head's ancestry,
  are the feature. Independence is preserved by rebuilding, not by disjoint
  branches: every head is rebuilt from its feature's commits each cycle, so
  retiring one is a composition that omits it.
- Publication: standing authorization for `fork`'s `integration` ref alone. A
  green `## Gate` on the exact commit is the authority; `main`, every
  `carry/*` head, and every upstream ref stay untouched by publication, and
  publishing never implies installing.
- Deletion marker prefix: `DELETEME/`. Creating, moving, or removing
  `DELETEME/<original-name>` requires an explicit human decision naming that
  branch. Maintenance never infers deletion from branch age, ownership,
  request state, or absence from the inventory. Every undeclared fork head
  remains unchanged and is reported.
- Open pull-request heads: **validated**. `feat/account-capacity-metadata` and
  `feat/recover-expired-token` are live review context on someone else's
  repository. Reconciliation confirms their exact heads from the fork and
  never acquires ownership of the refs; closing a request does not authorize
  renaming or deleting its branch.
- The fork also holds five branches from the merged July requests
  (`fix/usage-fetch-lease`, `fix/watch-external-refresh`,
  `fix/effective-token-status`, `fix/poll-exhausted-accounts`,
  `feat/display-last-good-usage`) and `fix/deferred-shared-history-resume`.
  They are undeclared heads: reported every cycle, never touched without an
  explicit human decision.
- Rerere: not relied on. The carried set is small and each head is meant to be
  reread against upstream rather than replayed from a recorded resolution.
- `scripts/reconcile-branches.sh` is this repository's entrypoint to the
  shared branch script; it declares these values and nothing else.
- Supervision: `scripts/reconcile-branches.sh --configure-supervision`
  converges this model into the bound checkout's own `supervisor.*` git
  config, which is where advisory tools read it — `/tend` judges a worktree
  against the integration branch and never proposes removing a carry head's
  worktree. It is derived state, not a second declaration:
  `--check-supervision` verifies it, and that this section still names these
  branches.

## Features

Every feature is a `carry/<feature>` head; the scratchpad records its exact
commits and its retirement condition. Absence is work. Work that adds a
feature writes its entry in the same change; an unrecorded feature is
unfinished work, because a later cycle reconciles only what this section names.

### Account capacity metadata

- `carry/account-capacity-metadata`. Offered as
  [#169](https://github.com/realiti4/claude-swap/pull/169).
- Each account row in `cswap`'s JSON output carries `subscriptionType` (only
  the literal `pro` or `max`) and `rateLimitMultiplier` (1, 5, or 20, derived
  from the credential's `rateLimitTier`) when the OAuth credential states
  them, and omits either field entirely when it does not. The projection is
  additive: a credential that is absent, unparseable, or not a JSON object
  yields no capacity fields rather than an error or a null.
- agentusage reads this as `account_capacity` per route and weights balancing
  by it; a row that silently loses these fields makes a 20× account look like
  a 1× one.
- Retires when upstream emits both fields with these types and this omission
  behavior.

### Owner-held expired token recovery

- `carry/recover-expired-token`. Offered as
  [#166](https://github.com/realiti4/claude-swap/pull/166).
- An explicit JSON-only recovery command refreshes an account whose stored
  token has expired, using Claude's own native refresh path rather than
  rotating stored backups: it verifies owner identity and credential state
  first, runs a bounded canary, cleans up its process tree, and reports
  PII-free outcomes.
- The sealed canary environment keeps `USER` and `LOGNAME`, without which
  Claude Code cannot resolve the session profile's macOS Keychain credential
  and reports the account as logged out.
- A matching session profile stays authoritative while idle: a stale backup's
  `invalid_grant` does not quarantine its lineage. An expired owner is exposed
  for native recovery; a fresh owner challenges the backup quarantine with the
  exact strictly read credential under the usage claim fence, and clears it
  only after a successful fetch and a post-fetch identity check. An unreadable
  Keychain, a failed fetch, or identity drift leaves the quarantine intact.
- Retires when upstream recovers an owner-held expired token without rotating
  backups, keeps the keychain-resolving environment, and does not quarantine
  an idle profile on a stale backup's refusal — all three, read in the code
  and exercised.

### Stranded shared-history resume refusal

- `carry/deferred-shared-history-resume`. Not offered.
- A resume that would attach to shared history the current profile can no
  longer reach is refused with a clear reason rather than started and
  stranded.
- Not offered because the behavior it protects is this machine's arrangement
  of profiles rather than a defect every claude-swap user hits; the fork
  branch `fix/deferred-shared-history-resume` predates that decision and is an
  undeclared head, not an open offer.
- Retires when upstream refuses the same resume.

### Already-routed sentinel

- `carry/already-routed-sentinel`. Never offerable.
- Session and recovery-canary launches of `claude` set `AGENTSURFACE_LAUNCH=1`,
  which tells the balancing shims on `PATH` (agentsurface ADR 0004) to exec the
  real binary: `cswap run N` keeps meaning slot N, and the recovery canary
  probes the owner profile it was aimed at. `exec_default` stays unstamped on
  purpose — a bare `cswap run` in an unmapped directory means "as if you typed
  claude", which balances.
- Never offerable because `AGENTSURFACE_LAUNCH` is a fleet concept upstream has
  no reason to know. It retires only if the shims stop existing.

### Fork packaging

- `carry/fork-packaging`. Never offerable.
- The fork identifies itself: the README says what the integration branch is
  and who consumes it, and `pyproject.toml` carries the fork's identity so an
  installed `cswap` is traceable to it.
- The fork's own CI runs the same three jobs upstream runs, on the fork's
  branches, so a candidate is proved before it is published.
- Test contracts that our carried features change are kept true here rather
  than inside the feature heads, so a feature head stays shaped the way its
  upstream offer is.
- It also holds test contracts that no carried feature changes: adjustments
  that make *upstream's own* suite pass on this machine. Two of them fix a
  genuine upstream defect — on macOS, the `TestUnreadableSourceIsNotAbsent`
  probes in `tests/test_move_accounts.py` and `tests/test_swap_accounts.py`
  chmod a `.creds-*.enc` that the healthy Keychain path never writes, so
  `Path.chmod` raises `FileNotFoundError`. Upstream's CI cannot see it: its
  macOS job runs only the two keychain suites, and the full-suite jobs are
  Ubuntu and Windows.
- Never offerable: it is entirely about being a fork. The macOS test fix above
  is the one part that *could* stand alone as an offer, and the operator
  decided on 2026-08-25 not to make it — upstream has left our two existing
  requests unreviewed since 2026-07-23, and a third would add review surface
  to a queue nobody is reading while buying nothing agentusage needs. Revisit
  only if upstream starts reviewing again. It retires when the fork does.

## Gate

From the candidate worktree, with `uv` installed. These are the three jobs
upstream's `.github/workflows/ci.yml` runs, not a subset:

```sh
uv sync --locked
uv run pytest
uv run pytest tests/test_macos_keychain_contract.py tests/test_macos_keychain.py -v -o faulthandler_timeout=60
```

The third command is macOS-only and is the job the previous installer-driven
rebase skipped. Skipping it is not an option on this machine: the recovery
feature's whole difficulty is keychain-resolving environments, and that is the
suite which proves them.

Then exercise, from that worktree's build, every changed feature's happy path
against real profiles — at minimum `cswap ls --json` for a capacity-metadata
change, and the recovery command's own JSON for a recovery change.

External proof: the fork's CI must be green on the exact candidate commit
before publication. Push the candidate to a newly named temporary branch on
the fork to obtain it, touching neither `integration` nor any preserved head.
A stale, partial, skipped, or cancelled run is not proof.

Obtaining that run is not automatic, and the reason is a conflict between two
requirements above. The fork's `ci.yml` fires on push to `main`, on pull
requests targeting `main`, and on `workflow_dispatch`; a push to a temporary
branch matches none of them. `workflow_dispatch` would answer, but GitHub only
offers it when the workflow declares it **on the default branch** — and the
default branch is `main`, which `## Branch model` requires to be an exact
upstream mirror, and upstream's `ci.yml` has no `workflow_dispatch`. The mirror
requirement removes the gate's own trigger.

The reliable path is therefore a pull request **on the fork**: open one from the
temporary candidate branch into the fork's own `main`. For a same-repository
pull request the workflow definition comes from the head ref, so the fork's
hardened three jobs run, and the run's `head_sha` is the exact candidate. This
is our repository, not upstream — it is not an offer, `watch-requests` does not
own it, and `## Upstream`'s stance about not opening review contexts we did not
create does not reach it. Close it once the run is green.

`gh workflow run ci.yml --ref <temporary-branch>` may still succeed on a stale
registration left from before `main` became a mirror. Where it does, the proof
is valid; do not rely on it continuing to work.

**Exception taken 2026-08-25, on `693a4f6`, by the operator.** GitHub's hosted
macOS capacity did not schedule the `macos-keychain` job for over four hours
across three independent runs on the exact candidate — a recurrence of the
"Actions delays in starting runs" incident GitHub had posted and marked
resolved the day before. `test` and `test-windows` were green on that commit;
the whole local gate was green, keychain suites included, against the real
`security` CLI. The operator accepted the local run as proof and the cycle
published on that basis.

This is a recorded exception, not a new standard. The gate above is still all
three jobs. A cycle may not take this exception on its own: it needs the
operator, for that cycle, on that commit, and it is written into the scratchpad
with the reason. If a later cycle finds itself wanting this twice, the thing to
fix is the runner, not the gate — a self-hosted macOS runner would end the
dependency, and the reason we could not simply add one here is that GitHub
reserves the `macos-latest` label for hosted runners, so accepting a
self-hosted label means editing `ci.yml`, which is carried, which changes the
candidate the run is meant to prove. That edit belongs to a cycle that starts
by making it, not to one trying to publish.

## Consumer

agentusage's install of `cswap`. After the leased push of `integration`, run:

```sh
~/code/cswax/scripts/install.sh --install --sha "$integration_sha"
```

It refuses a fork remote that is not `possibilities/claude-swap`, refuses a
dirty checkout, fast-forwards the bound checkout to the published commit,
refuses commits the fork does not have, and installs that exact commit with
`uv tool install --force`. It does not rebase, publish, inspect requests, or
decide which features are carried.

agentusage's `scripts/install-providers.sh` invokes this script and does
nothing else about the fork. An ordinary AgentStart install must never rewrite
or publish the fork; that is what this workshop exists to prevent.

## Notify

- Title: `claude-swap Maintenance`
- Group: `cswax.maintain`
