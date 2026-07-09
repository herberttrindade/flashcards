# Flashcards — English SRS

A single-file, no-build spaced-repetition flashcard app for English vocabulary, idioms, phrasal verbs and collocations. Everything lives in `flashcards.html` — no server-side code, no dependencies, no CDN.

Scheduling uses **FSRS** (Free Spaced Repetition Scheduler, v6 weights), implemented inline in the page.

## Features

- Two bundled decks: `english_words.json` (single words) and `english_flashcards.json` (idioms, phrasal verbs, collocations).
- Filter by source (words / phrases / mixed), by deck, and by CEFR level (A1–C1).
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
- Nothing is synced automatically across devices — use **Export progress** / **Export decks** to back up and **Import progress** / **Import deck** to restore elsewhere.

## Running locally

Card data is loaded with `fetch()`, which most browsers block for pages opened directly as a `file://` path. Serve the folder over HTTP instead, from inside the project directory:

```bash
python3 -m http.server 8791
```

Then open **http://localhost:8791/flashcards.html**.

(Any static server works — e.g. `npx serve` — but `python3 -m http.server` is the only one that also enables the automatic same-folder JSON deck discovery described above, since it publishes a directory listing.)

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
