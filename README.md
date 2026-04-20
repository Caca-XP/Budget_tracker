# Budget Tracker

A personal budget tracker — static frontend hosted on GitHub Pages, data stored in Supabase.

---

## Setup — do this once

### Step 1 — Create a Supabase project

1. Go to [supabase.com](https://supabase.com) and sign up (free)
2. Click **New project**
3. Give it a name (e.g. `budget-tracker`), set a database password, choose the **Sydney** region
4. Wait ~1 minute for it to spin up

### Step 2 — Create the table and seed your data

1. In your Supabase project, click **SQL Editor** in the left sidebar
2. Click **New query**
3. Open the file `supabase-setup.sql` from this repo, copy the entire contents, paste it in, and click **Run**
4. You should see "Success. No rows returned" — that means it worked

### Step 3 — Get your API credentials

1. In Supabase, go to **Settings** (gear icon) → **API**
2. Copy two values:
   - **Project URL** — looks like `https://abcdefgh.supabase.co`
   - **anon public** key — a long string starting with `eyJ...`

### Step 4 — Paste credentials into index.html

Open `index.html` and find these two lines near the top of the `<script>` section:

```js
const SUPABASE_URL     = "PASTE_YOUR_SUPABASE_URL_HERE";
const SUPABASE_ANON_KEY = "PASTE_YOUR_SUPABASE_ANON_KEY_HERE";
```

Replace the placeholder strings with your actual values. Example:

```js
const SUPABASE_URL     = "https://abcdefgh.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...";
```

Save the file.

### Step 5 — Push to GitHub

1. Go to [github.com](https://github.com) and create a **new repository** (call it `budget-tracker` or anything you like)
2. Make it **Public** (required for free GitHub Pages)
3. Follow the instructions GitHub shows to push your local files. In your terminal inside the project folder:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```

### Step 6 — Enable GitHub Pages

1. In your GitHub repo, go to **Settings** → **Pages** (left sidebar)
2. Under **Source**, select **GitHub Actions**
3. That's it — the workflow file (`.github/workflows/deploy.yml`) handles the rest

### Step 7 — Watch it deploy

1. Go to the **Actions** tab in your GitHub repo
2. You'll see a workflow called "Deploy to GitHub Pages" running
3. Once it shows a green ✓, click it and find the **live URL** at the bottom — something like:
   `https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/`

---

## Ongoing use

- **Adding transactions** — just use the app normally. Data is saved to Supabase instantly.
- **Editing data** — go to Supabase → **Table Editor** → `transactions`. It works like a spreadsheet.
- **Backup to CSV** — click the **↓ CSV** button in the app, or go to Supabase → Table Editor → Export as CSV.
- **Deploying changes** — any `git push` to `main` automatically redeploys the site via GitHub Actions.

---

## File structure

```
budget-tracker/
└── public/
    └── index.html                    ← the entire app (HTML + CSS + JS)
├── supabase-setup.sql            ← run once in Supabase SQL editor
├── README.md                     ← this file
└── .github/
    └── workflows/
        └── deploy.yml            ← GitHub Actions deployment config
```
#
