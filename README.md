# daily-contributions

Keeps a GitHub contribution streak alive with one small commit a day, and
renders that contribution graph as an animated snake on your profile.

## How it works

- **`.github/workflows/daily-commit.yml`** — runs on GitHub Actions every day
  at 07:23 UTC, appends a timestamp to `contributions.log`, and pushes the
  commit. Runs in the cloud, so it fires even if this machine is off.
- **`scripts/backfill.sh`** — a one-time local script to backdate commits
  over a past date range, so the graph has no gap before today. It commits
  locally only; nothing is pushed until you push yourself.
- **`.github/workflows/snake.yml`** — regenerates an SVG "snake" animation
  from your real contribution graph twice a day and publishes it to an
  `output` branch, using [Platane/snk](https://github.com/Platane/snk).

Commits only count toward your GitHub contribution graph if the commit
**author email is verified on your GitHub account**
(github.com/settings/emails — this includes your `@users.noreply.github.com`
address) and the repo is public (or you've enabled "include private
contributions" in your profile settings).

## Setup

1. **Create the GitHub repo.** Make a new repo (public, so contributions
   show up) — e.g. `daily-contributions` — and don't initialize it with a
   README.

2. **Set repo variables** the daily workflow needs (Settings → Secrets and
   variables → Actions → Variables):
   - `CONTRIB_EMAIL` — an email verified on your GitHub account (your GitHub
     noreply email is a good choice, found at github.com/settings/emails)
   - `CONTRIB_NAME` — your name (optional; defaults to your GitHub username)

3. **Backfill past dates (optional).** Review the tunables at the top of
   `scripts/backfill.sh`, then run it locally:

   ```bash
   GIT_AUTHOR_EMAIL="you@example.com" GIT_AUTHOR_NAME="Your Name" ./scripts/backfill.sh
   ```

   Inspect what it created before pushing:

   ```bash
   git log --oneline --date=short --pretty='%ad %s'
   ```

4. **Push.**

   ```bash
   git remote add origin git@github.com:<you>/daily-contributions.git
   git push -u origin main
   ```

5. **Embed the snake in your profile README.** In your special
   `<username>/<username>` repo's `README.md`:

   ```md
   <picture>
     <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/<you>/daily-contributions/output/github-contribution-grid-snake-dark.svg" />
     <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/<you>/daily-contributions/output/github-contribution-grid-snake.svg" />
     <img alt="github contribution snake animation" src="https://raw.githubusercontent.com/<you>/daily-contributions/output/github-contribution-grid-snake.svg" />
   </picture>
   ```

   The `output` branch is created automatically the first time
   `snake.yml` runs (via `workflow_dispatch` or a push to `main`).

## A note on authenticity

This fills the contribution graph with placeholder commits — it doesn't
reflect real work. Some people read a graph that's green every single day as
a signal of actual daily coding, including recruiters skimming a profile.
Nothing here is technically prohibited, but it's worth deciding for yourself
whether padding the graph this way represents you the way you want it to.
