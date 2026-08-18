#!/usr/bin/env bash
# Backfills past dates in the repo's git history so the contribution graph
# has no gaps between START_DATE and END_DATE. Run locally, once, before
# your first push — this is the only place history gets fabricated; the
# daily-commit.yml workflow only ever commits with today's real date.
#
# Usage:
#   GIT_AUTHOR_EMAIL=you@example.com GIT_AUTHOR_NAME="Your Name" \
#     ./scripts/backfill.sh
#
# Tunables (env vars, all optional):
#   START_DATE          first date to backfill, YYYY-MM-DD (default: 90 days ago)
#   END_DATE             last date to backfill, YYYY-MM-DD (default: yesterday)
#   SKIP_PROBABILITY    0-100, chance a given day gets zero commits (default: 25)
#   MAX_COMMITS_PER_DAY  upper bound on commits for an active day (default: 4)

set -euo pipefail

: "${GIT_AUTHOR_EMAIL:?Set GIT_AUTHOR_EMAIL to an email verified on your GitHub account}"
: "${GIT_AUTHOR_NAME:?Set GIT_AUTHOR_NAME to your name}"

START_DATE="${START_DATE:-$(date -v-90d '+%Y-%m-%d' 2>/dev/null || date -d '90 days ago' '+%Y-%m-%d')}"
END_DATE="${END_DATE:-$(date -v-1d '+%Y-%m-%d' 2>/dev/null || date -d 'yesterday' '+%Y-%m-%d')}"
SKIP_PROBABILITY="${SKIP_PROBABILITY:-25}"
MAX_COMMITS_PER_DAY="${MAX_COMMITS_PER_DAY:-4}"

export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
export GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"

cd "$(git rev-parse --show-toplevel)"

to_epoch() { date -j -f '%Y-%m-%d' "$1" '+%s' 2>/dev/null || date -d "$1" '+%s'; }
from_epoch_day() { date -j -f '%s' "$1" '+%Y-%m-%d' 2>/dev/null || date -d "@$1" '+%Y-%m-%d'; }

start_epoch=$(to_epoch "$START_DATE")
end_epoch=$(to_epoch "$END_DATE")
day=$((60 * 60 * 24))

total_commits=0
day_epoch=$start_epoch
while [ "$day_epoch" -le "$end_epoch" ]; do
  current_date=$(from_epoch_day "$day_epoch")

  if [ $((RANDOM % 100)) -lt "$SKIP_PROBABILITY" ]; then
    day_epoch=$((day_epoch + day))
    continue
  fi

  commits_today=$(( (RANDOM % MAX_COMMITS_PER_DAY) + 1 ))
  for _ in $(seq 1 "$commits_today"); do
    hour=$(printf '%02d' $((RANDOM % 24)))
    minute=$(printf '%02d' $((RANDOM % 60)))
    second=$(printf '%02d' $((RANDOM % 60)))
    ts="${current_date}T${hour}:${minute}:${second}"

    echo "${ts} backfill" >> contributions.log
    git add contributions.log
    GIT_AUTHOR_DATE="$ts" GIT_COMMITTER_DATE="$ts" \
      git commit -q -m "chore: contribution log ${current_date}"
    total_commits=$((total_commits + 1))
  done

  day_epoch=$((day_epoch + day))
done

echo "Created ${total_commits} backdated commits from ${START_DATE} to ${END_DATE}."
echo "Review with: git log --oneline --date=short --pretty='%ad %s'"
echo "Nothing has been pushed yet — inspect the log, then push when ready."
