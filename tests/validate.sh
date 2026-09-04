#!/bin/bash

set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

fail() {
    printf 'validate: %s\n' "$*" >&2
    exit 1
}

bash -n scripts/reconcile-branches.sh
bash -n scripts/install.sh
bash -n tests/validate.sh
for script in scripts/reconcile-branches.sh scripts/install.sh tests/validate.sh; do
    [ -x "$script" ] || fail "$script is not executable"
done
[ "$(readlink CLAUDE.md)" = AGENTS.md ] || fail "CLAUDE.md must link to AGENTS.md"

if command -v shellcheck >/dev/null 2>&1; then
    shellcheck --severity=warning scripts/reconcile-branches.sh scripts/install.sh \
        tests/validate.sh || fail "shellcheck found warnings"
fi

# The spec has every section the shared maintain skill reads by name.
for section in Purpose Upstream 'Branch model' Features Gate Consumer Notify; do
    grep -Fx "## $section" MAINTAIN.md >/dev/null \
        || fail "MAINTAIN.md is missing the section: ## $section"
done
grep -F 'Composition: **carry heads**' MAINTAIN.md >/dev/null \
    || fail "the branch model does not declare the carry-head composition"
grep -F 'scripts/install.sh --install --sha' MAINTAIN.md >/dev/null \
    || fail "the consumer does not name the installer"
grep -F "the fork's CI must be green on the exact candidate commit" MAINTAIN.md >/dev/null \
    || fail "the gate does not require external proof on the exact commit"
# shellcheck disable=SC2016 # Match literal Markdown text.
grep -F 'Title: `claude-swap Maintenance`' MAINTAIN.md >/dev/null \
    || fail "the notification title is missing"
if grep -F 'agentwiki' MAINTAIN.md >/dev/null; then
    fail "the spec depends on an external wiki policy"
fi

# Every carry head the branch model orders has an inventory entry, and every
# inventory entry names its head. A head in one list and not the other is how a
# feature silently stops being reconciled.
for head in \
    carry/account-capacity-metadata \
    carry/recover-expired-token \
    carry/deferred-shared-history-resume \
    carry/already-routed-sentinel \
    carry/fork-packaging; do
    [ "$(grep -cF "\`$head\`" MAINTAIN.md)" -ge 2 ] \
        || fail "$head is not both ordered and inventoried in MAINTAIN.md"
done

# The three CI jobs upstream runs are the gate, not a subset. The keychain
# contract job is the one an installer-driven rebase used to skip.
grep -F 'uv run pytest tests/test_macos_keychain_contract.py' MAINTAIN.md >/dev/null \
    || fail "the gate omits the macOS keychain contract job"

# The stance toward the two unreviewed requests is load-bearing: a cycle that
# refreshes them force-pushes a review context we did not open.
grep -F 'watch-requests' MAINTAIN.md >/dev/null \
    || fail "the spec does not hand open requests to watch-requests"
for request in 166 169; do
    grep -F "claude-swap/pull/$request" MAINTAIN.md >/dev/null \
        || fail "MAINTAIN.md does not name the open request #$request"
done

# The namespace entrypoint declares exactly the branch model the spec states
# and defers every mechanic to the shared script.
for declared in \
    'MAINTAIN_FORK_REPO=possibilities/claude-swap' \
    'MAINTAIN_UPSTREAM_REPO=realiti4/claude-swap' \
    'MAINTAIN_FORK_REMOTE=fork' \
    'MAINTAIN_UPSTREAM_REMOTE=upstream' \
    'MAINTAIN_MAIN_BRANCH=main' \
    'MAINTAIN_INTEGRATION_BRANCH=integration' \
    'MAINTAIN_CARRY_PREFIX=carry/' \
    'MAINTAIN_QUARANTINE_PREFIX=DELETEME/' \
    'MAINTAIN_PRESERVE_OPEN_PRS=1'; do
    grep -F "export $declared" scripts/reconcile-branches.sh >/dev/null \
        || fail "branch entrypoint does not declare $declared"
done
if grep -E 'git .*(push|fetch|update-ref)' scripts/reconcile-branches.sh >/dev/null; then
    fail "branch entrypoint carries namespace mechanics of its own"
fi
set +e
missing_skill_output=$(MAINTAIN_SKILL_DIR=/nonexistent scripts/reconcile-branches.sh --check 2>&1)
missing_skill_status=$?
set -e
[ "$missing_skill_status" -ne 0 ] || fail "branch entrypoint ran without the shared script"
printf '%s\n' "$missing_skill_output" | grep -F 'the maintain skill is not installed' >/dev/null \
    || fail "branch entrypoint does not explain a missing shared script"

# The installer is a consumer, never a maintainer. This is the property the
# whole workshop exists to establish: an ordinary machine converge must not be
# able to rewrite or publish the fork.
if grep -E 'git .*(rebase|push)' scripts/install.sh >/dev/null; then
    fail "the installer contains maintenance behavior"
fi
grep -F 'is not the published commit; refusing to install it' scripts/install.sh >/dev/null \
    || fail "the installer does not refuse an unpublished checkout"
grep -F 'has local changes; refusing to install them' scripts/install.sh >/dev/null \
    || fail "the installer does not refuse a dirty checkout"
grep -F 'not the requested' scripts/install.sh >/dev/null \
    || fail "the installer does not verify the exact requested commit"
grep -F 'run /maintain from ~/code/cswax' scripts/install.sh >/dev/null \
    || fail "the installer does not report upstream drift"
for mode in '--install --sha SHA' '--install --published' '--check'; do
    scripts/install.sh --help | grep -F -- "$mode" >/dev/null \
        || fail "the installer does not document $mode"
done
scripts/install.sh --check >/dev/null || fail "the installer's --check failed"
for bad in '--install' '--install --sha' '--install --sha nothex' '--install --published extra' '--bogus'; do
    set +e
    # shellcheck disable=SC2086 # Deliberate word splitting of the argument list.
    scripts/install.sh $bad >/dev/null 2>&1
    status=$?
    set -e
    [ "$status" -ne 0 ] || fail "the installer accepted: $bad"
done

# agentusage consumes the fork through this repository and does nothing else
# about it. A rebase helper reappearing there is the regression that matters.
providers="${CSWAX_AGENTUSAGE_PROVIDERS:-$HOME/code/agentusage/scripts/install-providers.sh}"
if [ -f "$providers" ]; then
    grep -F 'cswax/scripts/install.sh' "$providers" >/dev/null \
        || fail "agentusage does not install claude-swap through this workshop"
    if grep -E 'rebase|force-with-lease' "$providers" >/dev/null; then
        fail "agentusage's installer carries fork maintenance again"
    fi
fi

printf 'cswax validation passed.\n'
