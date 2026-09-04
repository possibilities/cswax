#!/bin/bash

set -euo pipefail

# The consumer step for the claude-swap fork: bind the bound checkout to a
# published `integration` commit and install exactly that commit. It never
# rebases, publishes, or touches a pull request — maintenance is `/maintain`,
# and an ordinary machine converge must not be able to rewrite the fork.
#
# `--install --sha SHA` is the hand-over after a maintenance cycle: install the
# exact commit the cycle published. `--install --published` is the unattended
# converge: resolve whatever `fork/integration` currently is and install that
# exact commit. Both refuse a dirty checkout, a foreign fork remote, and any
# commit the fork does not have.

die() {
    printf 'cswax installer: %s\n' "$*" >&2
    exit 1
}

usage() {
    printf 'Usage: scripts/install.sh --install --sha SHA|--install --published|--check\n'
}

check_only=0
expected_sha=
case "${1:-}" in
    --install)
        case "${2:-}" in
            --sha)
                [ "$#" -eq 3 ] || {
                    usage >&2
                    exit 64
                }
                expected_sha=$3
                [ "${#expected_sha}" -eq 40 ] || die "--sha must be a full lowercase commit SHA"
                case "$expected_sha" in
                    *[!0-9a-f]*) die "--sha must be a full lowercase commit SHA" ;;
                esac
                ;;
            --published)
                [ "$#" -eq 2 ] || {
                    usage >&2
                    exit 64
                }
                ;;
            *)
                usage >&2
                exit 64
                ;;
        esac
        ;;
    --check)
        check_only=1
        [ "$#" -eq 1 ] || {
            usage >&2
            exit 64
        }
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        usage >&2
        exit 64
        ;;
esac

checkout="${CSWAX_CSWAP_CHECKOUT:-$HOME/source/realiti4--claude-swap}"
branch=integration
fork_url="${CSWAX_CSWAP_FORK_URL:-https://github.com/possibilities/claude-swap.git}"
upstream_url="${CSWAX_CSWAP_UPSTREAM_URL:-https://github.com/realiti4/claude-swap.git}"
upstream_remote=upstream
upstream_branch=main
notify_group=cswax.install
log="${CSWAX_LOG:-$HOME/.local/state/cswax/install.log}"

if [ "$check_only" -eq 1 ]; then
    cat <<EOF
claude-swap fork installation:
  checkout: $checkout
  source: fork/$branch ($fork_url)
  upstream: $upstream_remote/$upstream_branch (maintained by /maintain from ~/code/cswax)
  action: align the clean checkout to a published integration commit and install it with uv
EOF
    exit 0
fi

[ "$(id -u)" -ne 0 ] || die "run as the target user, not root"
command -v git >/dev/null 2>&1 || die "git is required"
command -v uv >/dev/null 2>&1 || die "uv is required"

# A banner that never renders must not be the only record, so the log is
# written first and unconditionally.
report() {
    local message="$1"
    printf 'cswax installer: %s\n' "$message" >&2
    mkdir -p "$(dirname "$log")"
    printf '%s  %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$message" >>"$log"
    command -v terminal-notifier >/dev/null 2>&1 || return 0
    terminal-notifier -title 'claude-swap Fork' -message "$message" \
        -group "$notify_group" >/dev/null 2>&1 || true
}

remote_matches() {
    local actual="$1" expected="$2"
    local ssh="git@github.com:${expected#https://github.com/}"
    case "$actual" in
        "$expected" | "${expected%.git}" | "$ssh" | "${ssh%.git}") return 0 ;;
        *) return 1 ;;
    esac
}

if [ ! -d "$checkout/.git" ]; then
    printf 'cswax installer: cloning claude-swap upstream into %s.\n' "$checkout"
    mkdir -p "$(dirname "$checkout")"
    git clone --quiet --origin upstream "$upstream_url" "$checkout" \
        || die "cloning $upstream_url failed"
fi

actual_upstream_url="$(git -C "$checkout" remote get-url upstream 2>/dev/null || true)"
if [ -z "$actual_upstream_url" ]; then
    git -C "$checkout" remote add upstream "$upstream_url" || die "adding the upstream remote failed"
elif ! remote_matches "$actual_upstream_url" "$upstream_url"; then
    die "$checkout remote upstream points at $actual_upstream_url, not $upstream_url; refusing"
fi

actual_fork_url="$(git -C "$checkout" remote get-url fork 2>/dev/null || true)"
if [ -z "$actual_fork_url" ]; then
    git -C "$checkout" remote add fork "$fork_url" || die "adding the fork remote failed"
elif ! remote_matches "$actual_fork_url" "$fork_url"; then
    die "$checkout remote fork points at $actual_fork_url, not $fork_url; refusing"
fi

[ -z "$(git -C "$checkout" status --porcelain)" ] \
    || die "$checkout has local changes; refusing to install them"

git -C "$checkout" fetch --quiet fork "$branch" || die "fetching fork/$branch failed"
published="$(git -C "$checkout" rev-parse "fork/$branch")"

if [ -n "$expected_sha" ]; then
    [ "$published" = "$expected_sha" ] \
        || die "fork/$branch is $published, not the requested $expected_sha; nothing was installed"
fi

if ! git -C "$checkout" rev-parse --verify --quiet "refs/heads/$branch" >/dev/null; then
    git -C "$checkout" branch --quiet "$branch" "fork/$branch" \
        || die "creating the local $branch failed"
fi

current="$(git -C "$checkout" rev-parse --abbrev-ref HEAD)"
if [ "$current" != "$branch" ]; then
    git -C "$checkout" checkout --quiet "$branch" || die "checking out $branch failed"
fi

# Maintenance publishes a rewritten history under a lease, so the local branch
# may not fast-forward onto it. The tree is clean and the fork is authoritative
# for this branch, so taking the published commit wholesale loses nothing.
if git -C "$checkout" merge-base --is-ancestor HEAD "$published"; then
    git -C "$checkout" merge --quiet --ff-only "$published" \
        || die "$checkout@$branch cannot fast-forward to the published commit"
else
    git -C "$checkout" reset --quiet --hard "$published" \
        || die "aligning $checkout@$branch to the published commit failed"
fi

[ "$(git -C "$checkout" rev-parse HEAD)" = "$published" ] \
    || die "$checkout@$branch is not the published commit; refusing to install it"

# Drift is the condition this whole arrangement exists to surface: nothing
# rebases the fork unattended any more, so an install that notices upstream has
# moved past the carried set must say so. An unreachable upstream is a network
# fact, not a fork problem, and stays quiet.
if git -C "$checkout" remote get-url "$upstream_remote" >/dev/null 2>&1 \
    && git -C "$checkout" fetch --quiet "$upstream_remote" "$upstream_branch" 2>/dev/null; then
    upstream_ref="$upstream_remote/$upstream_branch"
    if ! git -C "$checkout" merge-base --is-ancestor "$upstream_ref" HEAD; then
        behind="$(git -C "$checkout" rev-list --count "HEAD..$upstream_ref")"
        report "integration trails $upstream_ref by $behind commit(s); run /maintain from ~/code/cswax"
    fi
fi

printf 'cswax installer: installing claude-swap from %s@%s.\n' "$checkout" "$published"
uv tool install --force "$checkout" >/dev/null || die "uv tool install failed"
command -v cswap >/dev/null 2>&1 \
    || die "cswap did not land on PATH (is ~/.local/bin on PATH?)"
printf 'cswax installer: cswap %s ready at %s.\n' \
    "$(cswap --version 2>/dev/null | tail -1)" "$(git -C "$checkout" rev-parse --short HEAD)"
