#!/bin/bash

set -euo pipefail

# cswax's entrypoint to the maintain skill's shared namespace script. It
# declares what MAINTAIN.md's Branch model says — the checkout, the remotes,
# the branch names, carry heads under `carry/`, validated open-request heads —
# and nothing else; the mechanics (a read-only check from a disposable
# snapshot and one atomic exact-leased push of declared refs that leaves all
# other heads unchanged) are the skill's and are tested there.
#
# The checkout was cloned with `--origin fork`, so the fork is `fork` and
# upstream is `origin`. That is the reverse of the usual reading; the two
# repository names below are what the script verifies the remotes against.

skill_dir="${MAINTAIN_SKILL_DIR:-$HOME/.local/share/agentstart/capabilities/packs/common/skills/maintain}"
script="$skill_dir/scripts/reconcile-branches.sh"
if [ ! -f "$script" ]; then
    printf 'cswax branches: the maintain skill is not installed at %s (render ~/code/agentguidance, or set MAINTAIN_SKILL_DIR)\n' \
        "$skill_dir" >&2
    exit 1
fi

export MAINTAIN_CHECKOUT="${CSWAX_CSWAP_CHECKOUT:-$HOME/src/claude-swap}"
export MAINTAIN_FORK_REPO=possibilities/claude-swap
export MAINTAIN_UPSTREAM_REPO=realiti4/claude-swap
export MAINTAIN_FORK_REMOTE=fork
export MAINTAIN_UPSTREAM_REMOTE=origin
export MAINTAIN_MAIN_BRANCH=main
export MAINTAIN_INTEGRATION_BRANCH=integration
export MAINTAIN_CARRY_PREFIX=carry/
export MAINTAIN_QUARANTINE_PREFIX=DELETEME/
export MAINTAIN_PRESERVE_OPEN_PRS=1

exec bash "$script" "$@"
