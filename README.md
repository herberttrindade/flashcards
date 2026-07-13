# Flashcards — English SRS

A single-file, no-build spaced-repetition flashcard app for English vocabulary, idioms, phrasal verbs and collocations. Everything lives in `flashcards.html` — no server-side code, no bundler. It loads the `@supabase/supabase-js` client from a CDN (`esm.sh`) for optional cloud sync — see [Cloud sync (Supabase)](#cloud-sync-supabase).

Scheduling uses **FSRS** (Free Spaced Repetition Scheduler, v6 weights), implemented inline in the page.

## Features

- Two bundled decks: `english_words.json` (single words) and `english_flashcards.json` (idioms, phrasal verbs, collocations).
- Filter by source (words / phrases / mixed), by deck, and by CEFR level (A1–C2).
- Grade each card **Again / Hard / Good / Easy** — FSRS recalculates difficulty, memory stability and the next due date.
- **Import deck** — add your own cards from a `.csv` or `.json` file. Click **Deck format ?** next to the button for the exact columns/fields expected and downloadable sample files. Cards that already exist (same deck + front + back) are skipped automatically, so re-importing a file is safe.
- **Export decks** — download the decks you've imported, as a JSON file you can re-import later or move to another browser/device.
- **Export progress / Import progress** — back up or restore your review history (per-card difficulty, stability, due dates, lapses).
- **Reset progress** — wipe all review history on this device (does not touch your imported decks).
- If the page is served by something that exposes a directory listing (see [Running locally](#running-locally)), any other `*.json` file with a `"cards"` array sitting next to `flashcards.html` is picked up automatically on load — handy for dropping in extra decks without clicking through the import dialog.

## How progress is stored

Everything (review progress and imported decks) is saved in the browser's `localStorage` — **per browser, per origin**. That means:

- Progress made on `http://localhost:8791/...` and progress made on the GitHub Pages URL are two separate stores.
- Clearing browser data / using a private window wipes it.
- Nothing is synced automatically across devices unless you sign in (see below) — otherwise use **Export progress** / **Export decks** to back up and **Import progress** / **Import deck** to restore elsewhere.

## Cloud sync (Supabase)

Signing in ("Sign in to sync", top of the page) mirrors your custom decks and FSRS review progress to a [Supabase](https://supabase.com) project, so they follow you to another browser/device. `localStorage` stays the source of truth for offline use — the app works exactly as before if you never sign in.

- **Auth**: email magic link (Supabase Auth). No passwords stored anywhere in this app.
- **What syncs**: cards you've imported (`Import deck`) and your FSRS progress per card. The three bundled decks (`english_words.json`, `english_flashcards.json`, `english_grammar_tenses.json`) stay static files and are never written to Supabase.
- **Security model**: the page embeds the Supabase project URL and its `anon`/`publishable` key directly in `flashcards.html`. That's expected — Supabase is designed so this key is safe to expose client-side. Actual access control is enforced by Postgres Row Level Security (RLS): every row in `cards` and `progress` carries a `user_id`, and the RLS policies only let a signed-in user read/write their own rows.

### One-time setup (already done for this project)

1. Create a project at [supabase.com](https://supabase.com) and grab its **Project URL** and **anon/publishable key** (Project Settings → API).
2. Run [`supabase/schema.sql`](supabase/schema.sql) once in the Supabase SQL Editor (Project → SQL Editor → New query → paste → Run). It creates the `cards` and `progress` tables with RLS enabled, scoped to `auth.uid()`. It's idempotent, so re-running it is safe.
3. Paste the URL/key into the `SUPABASE_URL` / `SUPABASE_ANON_KEY` constants near the top of the `<script type="module">` block in `flashcards.html`.
4. In Supabase → **Authentication → URL Configuration**, add every URL you'll actually open the app from (e.g. `http://localhost:8791/flashcards.html` and your GitHub Pages URL) to **Redirect URLs**, so the magic-link email can send people back to the right place.

## Downloading the ZIP and running it (no git required)

If you just want the app on your computer without using `git`:

1. Go to **https://github.com/herberttrindade/flashcards**.
2. Click the green **Code** button, then **Download ZIP**.
3. Find the downloaded file (usually in your `Downloads` folder) — it'll be named something like `flashcards-main.zip` — and double-click it to extract it. This creates a folder named `flashcards-main`.
4. Open that folder. You should see `flashcards.html`, `english_flashcards.json`, `english_words.json` and `README.md` inside it.
5. Now run it using one of the two options below:
   - **Simplest**: double-click `flashcards.html` inside that folder. This opens it straight from your file system — see [Option B](#option-b--open-the-file-directly-from-the-file-system-no-server) for which browsers this works in without extra setup (Firefox does; Chrome/Edge/Safari need a workaround or Option A instead).
   - **Most reliable (works in any browser)**: open a terminal, navigate into the extracted folder, and start a local server:
     ```bash
     cd ~/Downloads/flashcards-main
     python3 -m http.server 8791
     ```
     Then open **http://localhost:8791/flashcards.html** in your browser.

## Running locally

Card data is loaded with `fetch()`, which most browsers restrict for pages opened directly as a `file://` path. There are two ways to run it:

### Option A — local HTTP server (recommended)

Works in every browser and also enables automatic same-folder JSON deck discovery. From inside the project directory:

```bash
python3 -m http.server 8791
```

Then open **http://localhost:8791/flashcards.html**.

(Any static server works — e.g. `npx serve` — but `python3 -m http.server` is the only one that also enables the automatic deck discovery described above, since it publishes a directory listing.)

### Option B — open the file directly from the file system (no server)

Double-click `flashcards.html`, or drag it into a browser window / use **File → Open File…**. Whether the two bundled JSON decks load this way depends on the browser's `file://` security policy:

- **Firefox** loads local JSON files fine over `file://` out of the box — no setup needed.
- **Chrome, Edge and Safari** block `fetch()` of local files from a `file://` page by default (CORS). You'll see the app's "Couldn't load the card files" screen instead of your decks. Workarounds:
  - Use Firefox instead, or fall back to Option A.
  - *(Advanced, macOS, Chrome only)* launch a dedicated Chrome instance with local file access enabled — don't use your regular profile for this, it weakens `file://` security for that whole session:
    ```bash
    open -na "Google Chrome" --args --allow-file-access-from-files --user-data-dir="/tmp/chrome-flashcards" "file:///$(pwd)/flashcards.html"
    ```

Either way, imported decks and progress are still saved to `localStorage` — just remember that a `file://` page and an `http://localhost:...` page are different origins, so they keep **separate** local storage.

## Running on GitHub (GitHub Pages)

1. Push this repo to GitHub (already configured to push to `origin` → `github.com/herberttrindade/flashcards`).
2. In the repo, go to **Settings → Pages**.
3. Under **Build and deployment**, choose **Deploy from a branch**, pick the `main` branch and `/ (root)` folder, then save.
4. Wait a minute for the first deploy, then visit:
   ```
   https://herberttrindade.github.io/flashcards/flashcards.html
   ```
   (Note the explicit `/flashcards.html` — the file isn't named `index.html`, so it won't load from the bare repo URL.)

The two bundled JSON decks are already in the repo, so they'll load automatically. The auto-discovery-of-extra-JSON-files feature does **not** work on GitHub Pages (it has no directory listing) — use the **Import deck** button there instead.
