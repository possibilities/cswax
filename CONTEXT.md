# cswax context

**Workshop** — This repository, which owns the specification (`MAINTAIN.md`),
maintenance state, and consumer hand-over for the claude-swap fork; the
maintenance procedure itself is the shared `maintain` skill, which every
workshop runs.
_Avoid_: wrapper, patch repo.

**Integration branch** — `possibilities/claude-swap:integration`, every carried
feature composed above current upstream, and the only ref the installer builds
and binds.
_Avoid_: install branch, local main, feature branch.

**Main mirror** — Local `main` and `possibilities/claude-swap:main`, both
fast-forwarded to the exact current `realiti4/claude-swap:main` during every
maintenance cycle.
_Avoid_: integration base, development main.

**Carry head** — A `carry/<feature>` branch holding one carried feature, based
on current upstream and composed into `integration` in the declared dependency
order. A feature is repaired on its head; a landed one is dropped by removing
its head from the composition.
_Avoid_: stack commit, patch branch, feature branch (that is what an offer is).

**Carried feature** — Behavior `MAINTAIN.md` § Features requires that upstream
does not yet provide, and which therefore has a carry head. Every one has a
retirement condition.
_Avoid_: permanent patch, downstream fix.

**Offer** — A whole feature proposed upstream: a branch cut from current
`upstream/main`, written as upstream would write it, adversarially reviewed
before it is pushed, and tended by `watch-requests` rather than by a
maintenance cycle. #166 and #169 are the two open ones.
_Avoid_: carry head, PR branch as a synonym for carry head.

**Undeclared head** — Any branch on the fork that is not `main`, `integration`,
a current carry head, or a validated open-request head. Reported every cycle,
never touched without an explicit human decision.
_Avoid_: stale branch, dead branch (both imply a disposition maintenance may
not take).

**Consumer** — agentusage, which observes `cswap` and installs it through this
repository's `scripts/install.sh`. It does not rebase or publish the fork.
_Avoid_: dependent, downstream.
