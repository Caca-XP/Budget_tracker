# Budget Tracker Website — Planning Document

## 1. Overview

A single-page vanilla HTML/CSS/JS website with two core features:

1. **Transaction Form** — log a new expense/income entry (mirrors the Actuals sheet)
2. **Budget Table** — live read-only view of all budget categories with colour-coded status (mirrors the Budget sheet)

Data is persisted to a **CSV file on disk** via a tiny local Node.js server. The CSV can be opened and edited directly in Excel or LibreOffice at any time. The website reads the CSV on page load and writes to it on every form submission.

Single user only — no auth, no multi-tenancy.

---

## 2. Architecture

```
your-computer/
├── server.js          ← tiny Node.js HTTP server (no framework needed)
├── actuals.csv        ← the data file (open in Excel/LibreOffice to edit)
└── public/
    └── index.html     ← the entire frontend (HTML + CSS + JS)
```

### How it works

```
Browser (index.html)
    │
    │  GET /api/actuals        ← on page load, fetch all rows
    │  POST /api/actuals       ← on form submit, append one row
    ▼
server.js (Node.js, runs locally)
    │
    │  reads / appends
    ▼
actuals.csv
```

- `server.js` exposes exactly **two endpoints** — nothing more.
- The frontend never touches the file system directly — it always goes through the server.
- To edit data manually: just open `actuals.csv` in Excel or LibreOffice, change rows, save. The next page load will reflect your changes.

### Running locally

```bash
node server.js
# then open http://localhost:3000 in your browser
```

---

## 3. CSV File Format

`actuals.csv` — one header row, one row per transaction, comma-separated.

```
date,type,amount,fortnight,description
2026-03-18,Salary,2491.21,1,Payday
2026-03-19,Emergency,72,1,Auto
...
```

Column order must be preserved. Dates are stored as `YYYY-MM-DD`.

> **To add/edit rows manually:** open in Excel or LibreOffice Calc, make changes, Save As CSV (keep the same filename and format). Do not change the header row.

---

## 4. Server API (server.js)

Two endpoints only:

### GET /api/actuals
- Reads `actuals.csv` from disk.
- Parses it into JSON.
- Returns: `200 OK` with JSON array of transaction objects.

### POST /api/actuals
- Receives a single transaction object as JSON in the request body.
- Validates all required fields are present.
- Appends one new row to `actuals.csv`.
- Returns: `201 Created` with the saved transaction object.

### Static file serving
- `GET /` → serves `public/index.html`
- No other routes.

---

## 5. Data Model

### 5.1 Transaction object

```js
{
  date:        "2026-04-18",            // ISO date string YYYY-MM-DD
  type:        "Spending",              // transaction type string
  amount:      23.00,                   // number, always positive
  fortnight:   3,                       // integer, min 1, max derived from date
  description: "Eating out"            // free-text string
}
```

### 5.2 Budget config (hardcoded in frontend, never changes at runtime)

```js
const BUDGET_CONFIG = [
  { type: "Rent",                  budget: 840  },
  { type: "Transport",             budget: 80   },
  { type: "Spending",              budget: 120  },
  { type: "Travel",                budget: 120  },
  { type: "Emergency",             budget: 72   },
  { type: "Miscellaneous expense", budget: 90   },
  { type: "Investment",            budget: 1160 },
];
// Total row is computed, not stored
// Salary is NOT in BUDGET_CONFIG — it is income, not a budget category
```

---

## 6. Core Business Logic (frontend JS)

### 6.1 Fortnight Calculation

Anchor date: **18 March 2026** (first payday).

```js
const ANCHOR = new Date("2026-03-18");

function getFortnight(dateStr) {
  const d = new Date(dateStr);
  return Math.floor((d - ANCHOR) / (14 * 86400 * 1000)) + 1;
}
```

- Called automatically when the date field changes.
- Result is clamped: **min 1, max = getFortnight(today)**.
- User can manually override within that range.

### 6.2 Budget Table Derived Columns

Recalculated from scratch on every render. Let:
- `currentFN` = `MAX(fortnight)` across all transactions
- `allTx` = full transactions array (loaded from CSV + any newly submitted this session)

#### Budget Left for Current Fortnight
```
budgetLeft(type) =
  budget
  - SUM(amount where type matches AND fortnight == currentFN)
```

#### Debt Accrued
```
pastSpend(type) = SUM(amount where type matches AND fortnight < currentFN)
debtAccrued(type) = MAX(0, pastSpend - budget * (currentFN - 1))
```

#### Allowed Spending to Cover Debt
```
allowedSpending(type) =
  budgetLeft - MAX(0, debtAccrued + IF(budgetLeft < 0, -budgetLeft, 0))
```

#### Total Row
Sum of each derived column across all BUDGET_CONFIG types (excludes Salary).

### 6.3 Salary Transactions

- Selectable in the form as a transaction type.
- A Salary entry **can push `currentFN` higher** if its fortnight exceeds all others.
- Salary amounts are **excluded from all budget calculations**.
- Salary rows do **not appear** in the budget table.

---

## 7. UI — Sections & Behaviour

### 7.1 Transaction Form

| Field | Input | Default | Constraint |
|---|---|---|---|
| Transaction Type | `<select>` | — | Required |
| Amount | `number` | — | > 0, step 0.01 |
| Description | `text` | — | Required |
| Date | `date` | Today | Required |
| Fortnight | `number` | Auto from Date | Min 1, max getFortnight(today) |

**Behaviour:**
- Changing Date auto-updates Fortnight via `getFortnight()`.
- User can override Fortnight within the allowed range.
- On submit: POST to `/api/actuals`, then re-render budget table and recent transactions panel, then reset form to defaults.
- Show a **brief success toast** on submission ("Transaction saved ✓").
- Show an **error toast** if the server is unreachable.

### 7.2 Budget Table (read-only)

Columns:

| Transaction Type | Budget | Budget Left (current FN) | Debt Accrued | Allowed Spending |
|---|---|---|---|---|

Last row is always **Total**.

**Colour rules (row-level, Total row included):**

| Condition | Style |
|---|---|
| `allowedSpending < 0` OR `debtAccrued > 0` | 🔴 Red background |
| `budgetLeft === 0` AND `debtAccrued === 0` | 🟡 Yellow background |
| Otherwise | Default |

Red takes priority over yellow.

### 7.3 Recent Transactions Panel

- Shows the **last 3 transactions** added this session (all types including Salary).
- Collapsible: a toggle button shows/hides the list.
- Collapsed by default on mobile to save space.
- Each entry shows: date, type, amount, description.
- Does **not** show the full historical list — just the 3 most recent additions this session.

---

## 8. Page Layout

### Desktop (side-by-side)

```
┌──────────────────────────────────────────────────────┐
│  HEADER  "Budget Tracker"              FN: 3 badge   │
├────────────────────┬─────────────────────────────────┤
│  Transaction Form  │  Budget Table (live, read-only) │
│                    │                                 │
│  Type    [▼]       │  Type | Budget | Left | Debt.. │
│  Amount  [    ]    │  Rent   840      0      🔴      │
│  Desc    [    ]    │  ...                            │
│  Date    [    ]    │  Total  2482    ...             │
│  FN      [  3 ]    │                                 │
│  [Submit]  ✓ toast │                                 │
├────────────────────┴─────────────────────────────────┤
│  ▼ Recent (3)  [toggle]                              │
│  18 Apr · Spending · $23 · Eating out                │
│  16 Apr · Rent · $840 · Cash                         │
│  16 Apr · Travel · $120 · in emergency               │
└──────────────────────────────────────────────────────┘
```

### Mobile (stacked)

```
┌──────────────────────┐
│  HEADER   FN: 3      │
├──────────────────────┤
│  Transaction Form    │
│  ...                 │
│  [Submit]            │
├──────────────────────┤
│  ▶ Recent (3)        │  ← collapsed by default
├──────────────────────┤
│  Budget Table        │
│  (horizontally       │
│   scrollable)        │
└──────────────────────┘
```

Budget table scrolls horizontally on small screens rather than wrapping.

---

## 9. Aesthetic Direction

- **Theme:** Dark financial terminal — monospace numbers, clean structure, no decoration.
- **Fonts:** `IBM Plex Mono` for all numbers and data cells (Google Fonts), `DM Sans` for labels, headings, and UI text.
- **Colours:**
  - Background: `#0d1117` (deep navy)
  - Surface/card: `#161b22`
  - Border: `#30363d`
  - Accent: `#00e5cc` (electric teal) — used on focus rings, the submit button, the FN badge
  - Danger row: `#ff4d4d` at 15% opacity background, `#ff4d4d` text
  - Warning row: `#f5c518` at 15% opacity background, `#f5c518` text
  - Body text: `#e6edf3`
  - Muted text: `#8b949e`
- **Details:** teal glow on form field focus, smooth background-color transition on table rows, toast slides in from bottom-right.

---

## 10. Seed Data

Pre-load `actuals.csv` with all rows from the Actuals screenshot so the table starts in a meaningful state (fortnight 3, as of 18 Apr 2026).

```csv
date,type,amount,fortnight,description
2026-03-18,Salary,2491.21,1,Payday
2026-03-19,Emergency,72,1,Auto
2026-03-19,Spending,72.09,1,Sake festival for Sep
2026-03-20,Investment,1160,1,Stake
2026-03-21,Transport,40,1,Transport NSW
2026-03-21,Spending,25.36,1,Eating out
2026-03-21,Miscellaneous expense,6.98,1,Soap
2026-03-21,Spending,10.6,1,Daiso
2026-03-21,Spending,17.22,1,My unique life
2026-03-21,Rent,840,1,Cash
2026-03-24,Travel,120,1,in emergency
2026-03-26,Miscellaneous expense,13,1,Plants
2026-03-28,Miscellaneous expense,8.35,1,Catnip plant
2026-03-28,Spending,9.05,1,Snacks
2026-03-28,Miscellaneous expense,5,1,Yoga mat
2026-03-29,Transport,40,1,Transport NSW
2026-04-01,Salary,2491.21,2,Payday
2026-04-02,Emergency,72,2,Auto
2026-04-02,Travel,120,2,in emergency
2026-04-01,Investment,1160,2,Stake
2026-04-02,Spending,33.5,2,Eating out
2026-04-02,Miscellaneous expense,5.85,2,Dental and Bleach
2026-04-03,Spending,50.87,2,Easter show
2026-04-05,Rent,840,2,Cash
2026-04-07,Spending,125,2,CBA ball
2026-04-07,Transport,35,2,Transport NSW
2026-04-11,Spending,54.05,2,Easter show expenses
2026-04-15,Salary,2491.21,3,Payday
2026-04-15,Spending,16.75,3,Anime Rave
2026-04-15,Transport,40,3,Transport NSW
2026-04-15,Investment,1160,3,Stake
2026-04-15,Spending,10,3,Easter show expenses
2026-04-16,Emergency,72,3,Auto
2026-04-16,Travel,120,3,in emergency
2026-04-16,Rent,840,3,Cash
2026-04-18,Spending,23,3,Eating out
```

---

## 11. Implementation Order (suggested)

Work in this sequence so each step is independently testable:

1. **`server.js`** — GET and POST endpoints + static file serving. Test with `curl` before touching the frontend.
2. **`actuals.csv`** — create with seed data above.
3. **`index.html` — data layer** — on page load, fetch `/api/actuals`, store in a JS array, `console.log` it. No UI yet.
4. **`index.html` — budget logic** — implement `getFortnight()` and the three derived column functions. Unit-test them in the browser console against known values from the spreadsheet screenshots.
5. **`index.html` — budget table render** — render the table from BUDGET_CONFIG + derived columns. Verify colours match the screenshots.
6. **`index.html` — transaction form** — wire up the date→fortnight auto-calc, validation, POST, and re-render.
7. **`index.html` — recent transactions panel** — show/hide toggle + last 3 entries.
8. **CSS** — apply the aesthetic direction last, once logic is confirmed correct.
