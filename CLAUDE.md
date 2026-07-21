# Brand Matrix — Project Context

This is a **copy** of `d:\Project\social-media-health` (the original, still-running production-ish app), created to safely upscale/redesign without touching the live version. Database is `brand_matrix_v2` (cloned from `brand_matrix`), app runs on port 8003 by convention (`APP_URL` in `.env`), original runs on 8000.

## What this app does

A social media health-scoring dashboard ("Brand Matrix") for tracking brand accounts across reporting cycles (periods with follower/reach/view/engagement numbers), computing configurable Growth/Visibility/Engagement/Health scores, and generating AI summaries.

Stack: Laravel 12 + Inertia.js (Vue 3 adapter) + Vue 3 Composition API + Vite. Tailwind CSS v4. MySQL. Laravel Fortify for auth (login/register/reset-password/profile-update/password-update only — no 2FA, no passkeys, no email verification).

## Core domain model

- **Account** — a brand/client being tracked. Has many Cycles.
- **Cycle** — one reporting period for an account: `cycle_start_date`, `cycle_end_date`, `start_follower`, `end_follower`, `reach`, `views`, `engagement`. All scores are *computed*, not stored (except `ai_summary`/`ai_summary_generated_at`).
- **ScoreBucket** (`metric`, `min_rate`, `score`) — user-configurable thresholds mapping a raw rate to a 0-100 score. Metrics: growth, reach, view, er_reach, er_follower.
- **LabelBucket** (`metric`, `min_score`, `label`) — maps aggregate scores to text labels (SIP/BAGUS/CUKUP/KURANG/PARAH). Metrics: visibility, engagement, health.
- **FormulaWeight** — user-configurable weights for the 3 aggregate formulas (Visibility = f(reach_score, view_score); Engagement = f(er_reach_score, er_follower_score); Health = f(growth_score, visibility_rate, engagement_score)). Auto-normalizes if weights don't sum to 1.
- **FilterSummary** — log of AI-generated summaries for filtered cycle sets (not cached/deduped, every generation is a new row).

**Everything scoring-related is user-editable via a Settings UI** — bucket thresholds, scores, labels, formula weights. Nothing is hardcoded. This was an explicit, repeated design requirement throughout the build.

### `MetricCalculator` service (the core engine)

`app/Services/MetricCalculator.php` — `calculate(Cycle $cycle, ?Collection $scoreBuckets, ?Collection $labelBuckets, ?Collection $formulaWeights): array`. Computes 5 rates (growth_rate, reach_rate, view_rate, er_reach_rate, er_follower_rate), resolves each to a score via `ScoreBucketResolver` (highest `min_rate` ≤ value wins, rounds to 4 decimals to avoid float boundary bugs), computes 3 weighted aggregates, resolves each to a label.

`ScoreBucketResolver` is reused for both score buckets and label buckets — same "highest min ≤ value wins" semantics.

## AI summarization

Two swappable providers behind `SummaryProvider` interface: `GroqSummaryService` (Groq's OpenAI-compatible API) and `GeminiSummaryService` (Google Gemini `generateContent` API). `SummaryProviderResolver` picks based on explicit request param or `config('services.ai_summary.provider')` (env `AI_SUMMARY_PROVIDER`).

**Prompts are English** (system + user data), with an explicit instruction line: *"Write your final answer in Bahasa Indonesia... Do all your reasoning in English internally, but the output text must be entirely in Bahasa Indonesia."* This was a deliberate fix — asking the model to reason AND write in Indonesian directly caused incomplete/truncated summaries; English reasoning + Indonesian-only output instruction fixed it.

Two prompt-building traits: `BuildsSummaryPrompt` (single cycle) and `BuildsFilterSummaryPrompt` (multi-cycle aggregate, includes raw metrics + per-metric rates/scores + aggregate scores per cycle block — NOT just the 3 rolled-up scores, since raw data makes the AI more precise per explicit user request).

Three places generate AI summaries, each independently persisted:
1. **Single cycle** (`CycleController::summarize`) → saves to `cycles.ai_summary`
2. **Filtered cycle set** (`CycleController::summarizeFiltered`) → logs to `filter_summaries` table (no caching — every click = new row, by design; caching was discussed and explicitly rejected due to staleness risk)
3. **Per-account** (`AccountController::summarize`) → saves to `accounts.ai_summary` (added later, mirrors cycle pattern)

**Gemini model gotchas** (hard-won): `gemini-2.0-flash` → 0 quota on this key. `gemini-2.5-flash-lite` → deprecated for new users. `gemini-3-flash-preview` → only 20 requests/DAY on free tier (hit this limit repeatedly). Current working default: `gemini-flash-lite-latest` (an alias Google keeps pointed at a current model, most quota-forgiving). If you hit quota errors again, check `GEMINI_MODEL` in `.env` first — this has been the recurring failure point.

`maxOutputTokens`/`max_tokens` must be generous (Gemini: 1024, Groq: 700) — newer "preview" Gemini models burn budget on internal reasoning before visible output; too-low caps cause silent truncation. Both services check `finishReason`/`finish_reason` and raise a clear "ran out of tokens" error instead of returning empty text.

## Auto-fill follower logic (Cycle create form)

When adding a cycle, `start_follower`/`end_follower` auto-fill from **neighboring cycles of the same account**, triggered by the date fields (not the account dropdown):
- Setting **Cycle Start** date → looks for a prior cycle ending `<=` that date → uses its `end_follower`. If none, looks for a later cycle starting `>` that date → uses its `start_follower`. If neither, stays 0.
- Setting **Cycle End** date → looks for a next cycle starting `>=` that date → uses its `start_follower`. If none, stays 0 (deliberately NO fallback to a previous cycle's end_follower — that was a bug that got removed; see git history / conversation if resurrected).

Endpoint: `GET /accounts/{account}/neighboring-cycle?start_date=...&end_date=...` (`CycleController::neighboring`, private helpers `resolveStartFollower`/`resolveEndFollower`). Boundary comparisons are `<=`/`>=` not `<`/`>` — exact-date adjacency between back-to-back cycles must resolve to the *adjacent* cycle, not skip past it (this was a real bug, fixed).

Only fires in create mode (`!editingCycle`), never overwrites values when editing an existing cycle.

## Filtering (Cycles index page)

Filters: search (account name), account_id, health_label, and a **month RANGE** (`month_from`/`month_to`, both `Y-m` format) — not a single month. A cycle is bucketed by the month of its `cycle_start_date` specifically (a cycle spanning May 31–June 30 counts as May). All filters live in one "Filter" modal (not separate inline dropdowns) with an active-filter-count badge, opened via a funnel-icon button. Draft state pattern: modal edits draft refs, only commits to live filter refs + triggers navigation on "Apply."

PDF export (`cycles-pdf`, dompdf/Blade) respects the same filters and can embed an AI-generated summary if one was generated first (passed as `ai_summary` query param).

## Account growth charts

`AccountGrowthModal.vue` — Chart.js line charts (installed as an npm dep) in a tabbed layout: Overview (followers, growth rate), Volume (reach/views/engagement — kept as separate charts, not overlaid, because raw counts vs. percentage are wildly different scales), Scores (combined Visibility/Engagement/Health on one 0-100 scale chart), Engagement Rate (ER-of-reach vs ER-of-followers), and an AI Summary tab (reuses the account-level summarize endpoint). "Download PDF" button re-renders all charts offscreen as PNG data URLs (dompdf can't render live canvases) and POSTs them to `AccountController::pdf`.

## UI/UX patterns established (keep consistent when extending)

- **Design tokens**: CSS custom properties (`--bg`, `--surface`, `--ink`, `--accent`, `--status-{sip,bagus,cukup,kurang,parah}-{bg,ink}`) in `resources/css/app.css`, light/dark via both `prefers-color-scheme` media query AND `[data-theme]` attribute override (theme toggle in `AppLayout.vue` sets `data-theme` + localStorage).
- **Modals**: NO backdrop-click-to-close (explicit X button only) — this was a deliberate fix after user feedback that accidental backdrop clicks were losing form input ("user is stupid and messy, often miss click" — direct quote, keep this UX principle).
- **Searchable dropdowns**: `SearchableSelect.vue` — custom combobox (button + search input + filtered list) used where a plain `<select>` would have too many options (e.g. Account picker in Add Cycle). Native `<select>` can't have a search box, hence the custom component.
- **Tabs over stacked forms**: when a modal has 2+ distinct sections (e.g. Profile/Password in `ProfileDropdown.vue`, or the 5 tabs in `AccountGrowthModal.vue`), use a tab bar, not stacked forms with dividers — this was an explicit "fix the awful layout" correction.
- **Status badges**: `StatusBadge.vue` for health/visibility/engagement labels. Cycles table only shows the Health label badge (not Visibility/Engagement) — deliberate declutter decision. Cycle detail modal shows all three.
- **Pagination**: `LengthAwarePaginator` pattern (manual, since health-label filtering happens post-computation in PHP, not SQL) for Cycles; standard `->paginate()` for Accounts. Same frontend pagination-footer markup reused in both pages (page-number buttons, "Showing X–Y of Z").

## Known environment gotchas

- **XAMPP MySQL crashes**: This has happened multiple times (unclean shutdowns → InnoDB `MLOG_CHECKPOINT` corruption, and separately a `mysql` system-table format corruption causing `proxies_priv` errors). Recovery playbook if it recurs: (1) back up `C:\xampp\mysql\data` before touching anything, (2) check `C:\xampp\mysql\data\mysql_error.log` for the *actual* error rather than guessing, (3) InnoDB corruption → `mysqld.exe --innodb_force_recovery=6` run directly (not via XAMPP GUI, which masks the real error by auto-restarting) to get read access, `mysqldump` everything out, then rebuild a fresh `data` dir via `mysql_install_db.exe` and re-import. System-table corruption is a *different* fix (`mysql_install_db` regenerates just the `mysql` subfolder) — don't conflate the two error types.
- **No Administrator rights in the Claude Code environment** — cannot run `New-NetFirewallRule` or other elevated commands. Any Windows Firewall / LAN-access setup must be done by the user directly.
- **PowerShell tool** in this environment is Windows PowerShell 5.1 — no `&&`/`||`, no ternary, no `2>&1` redirect on native exes (wraps stderr in NativeCommandError even on success). Bash tool is Git Bash/POSIX — prefer it for anything Unix-shaped (rm, curl, ps-like checks via `tasklist`/`netstat`).
- **`cd` does not persist** between Bash tool calls in this environment — every command starts from the same default cwd. Use full paths or single chained commands, not `cd x && ...` across separate tool calls.

## Testing

`php artisan test` — 17 tests, all in `tests/Unit/MetricCalculatorTest.php` (bucket boundary semantics, zero-division safety, custom weights/buckets) and `tests/Feature/ExampleTest.php` (auth redirect smoke tests). SQLite in-memory for tests (`phpunit.xml`) — this is why `CycleController` uses portable Carbon date-range queries (`whereBetween`) instead of MySQL-only `DATE_FORMAT()` raw SQL for month filtering.

Always run `npm run build` + `php artisan test` after frontend/backend changes before considering a task done — this was the consistent verification pattern throughout the original build.
