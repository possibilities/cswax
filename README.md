# cswax

The workshop for this machine's [claude-swap](https://github.com/realiti4/claude-swap)
fork: the specification the fork must satisfy, the state between maintenance
cycles, and the two scripts a cycle calls.

- `MAINTAIN.md` — the specification. The shared `maintain` skill reads it by
  section name and knows nothing about claude-swap that is not in it.
- `SCRATCHPAD.md` — current maintenance state: the last completed baseline,
  one entry per carried feature, and a dated history.
- `scripts/reconcile-branches.sh` — the fork's branch namespace, declared and
  reconciled through the skill's shared script.
- `scripts/install.sh` — the consumer step: bind the bound checkout to a
  published `integration` commit and install it.

Run a cycle with `/maintain` from this checkout. The fork carries two features
that are open pull requests upstream ([#166], [#169], unreviewed since
2026-07-23) and three that were never offerable; each has a retirement
condition, and the fork collapses to a stock install when upstream carries
them all.

[#166]: https://github.com/realiti4/claude-swap/pull/166
[#169]: https://github.com/realiti4/claude-swap/pull/169
