# Next.js + Hono (Vercel Functions) + Firebase Admin + Turborepo Starter

A minimal, **production-minded** starter you can fork for any new project:
- **Frontend**: Next.js (App Router, TypeScript, i18n with next-intl)
- **Backend**: Hono
  - **locally**: single Node server
  - **on Vercel**: file-based **Serverless Functions**
- **Database/Storage**: Firebase (Admin SDK) with **Emulators** locally
- **Monorepo**: Turborepo + shared packages (i18n, types), easy to add more apps (admin, dashboard, landing)
- **Seed script**: quick Node/TS script to push demo data
- **CORS** enabled for local dev

> Swap Firebase later? Replace `apps/api/src/lib/*` and service code; everything else stays.

---

## Why this is a good Next.js starter

- **SSR/ISR best practices**: Server Components by default, simple fetch caching via `next: { revalidate }` and tags.
- **Clean backend separation**: small, per-resource handlers in Hono; reuse the same router for **local** and **Vercel Functions**.
- **Zero giant files**: each CRUD action is a tiny file; controllers/services are easily testable.
- **Scales to many frontends**: Turborepo lets you add `apps/admin`, `apps/dashboard`, `apps/landing` later.
- **Local-first**: Firebase Emulators + a seed script → iterate fast without burning costs.
- **i18n ready**: locale middleware (`en`, `mk`) and message bundles.

---

## Tech choices at a glance

- **Next.js** App Router (14+)
- **Hono** for backend HTTP (tiny, fast; 1 codebase for local & serverless)
- **Firebase Admin** for DB/Auth/Storage access in Node runtime
- **next-intl** for i18n
- **Turborepo** for monorepo management

---

## Project layout

```
.
├─ apps/
│  ├─ web/                  # Next.js frontend
│  └─ api/                  # Hono backend (Node locally, Vercel functions in prod)
├─ packages/
│  └─ i18n/                 # shared i18n config (locales, defaultLocale)
├─ tools/
│  └─ scripts/seed.ts       # seed Firestore with demo data
├─ firebase.json            # Emulator config
├─ vercel.json              # Functions + routes mapping
├─ turbo.json               # Turborepo pipeline
├─ pnpm-workspace.yaml
└─ .env.example
```

---

## Prerequisites

- **Node 18.18+**
- **pnpm 9+** (or npm/yarn, but scripts assume pnpm)
- (Optional) **Firebase CLI** for emulators: `npm i -g firebase-tools`

---

## 1) Create your repo and install

```bash
pnpm i
cp .env.example .env
```

Set environment variables in `.env`:
- `NEXT_PUBLIC_API_BASE=http://localhost:8787`
- `FIREBASE_STORAGE_BUCKET=your-project.appspot.com`
- For **local** Admin auth, either:
  - set `GOOGLE_APPLICATION_CREDENTIALS=/abs/path/serviceAccount.json`, or
  - set `FIREBASE_SERVICE_ACCOUNT` to the **stringified** service account JSON.

---

## 2) (Recommended) Start Firebase Emulators

In one terminal:
```bash
firebase emulators:start
```

This exposes:
- Auth: `127.0.0.1:9099`
- Firestore: `127.0.0.1:8080`
- Storage: `127.0.0.1:9199`
- UI: `http://localhost:4000`

---

## 3) Run dev servers

In another terminal:
```bash
# start Next.js and Hono locally (and any other apps later)
pnpm dev
```

- **Frontend**: http://localhost:3000 → go to `/en/projects`
- **Backend**: http://localhost:8787 (`/health`, `/projects` endpoints)
- **Emulators UI**: http://localhost:4000

> The backend enables permissive CORS for local dev.

---

## 4) Seed demo data

```bash
pnpm seed
```

This writes 5 `projects` to Firestore. Open the Emulator UI to verify.

---

## 5) Try the app

- Visit **`http://localhost:3000/en/projects`** → you should see the seeded projects.
- Click **Create** to POST a new project.
- Open a project detail to **Delete** it.

> The frontend sends an `Authorization: Bearer` header using `DEMO_ID_TOKEN` from `.env`. In real apps, use Firebase Web SDK to obtain a real ID token and send it.

---

## Environment variables (Prod / Vercel)

Set these in Vercel Project Settings → Environment Variables:

- `FIREBASE_SERVICE_ACCOUNT` → paste full JSON (as single line)
- `FIREBASE_STORAGE_BUCKET` → `your-project.appspot.com`
- `NEXT_PUBLIC_API_BASE` → `https://<your-vercel-domain>/api`

Deploying to Vercel will automatically map API routes via `vercel.json`:
```
/api/projects  -> apps/api/api/projects/index.ts
```

> We force **Node runtime** for functions using Firebase Admin.

---

## Adding more apps

To add an admin or dashboard later:
1. Copy `apps/web` → `apps/admin`
2. Adjust branding, routes, auth strategy.
3. `pnpm dev` runs them all in parallel; Vercel can host each as a separate project or a single monorepo.

---

## Backend structure & patterns

- **Small files** per CRUD action under `apps/api/src/routes/<resource>/`.
- **Shared logic** (Firebase init, auth middleware, zod schemas) under `src/lib`, `src/middleware`, `src/schemas`.
- **Local dev** runs **one server** (`tsx src/index.ts`); **Prod** uses Vercel functions in `apps/api/api/**` that mount the same routers.

---

## Swapping Firebase later

- Replace `apps/api/src/lib/firebaseAdmin.ts` and any service code using Firestore/Storage.
- Keep route handlers & frontend untouched.

---

## Common gotchas

- **Firebase Admin on Edge**: not supported. We force Node runtime.
- **CORS**: Hono enables permissive CORS in dev. Lock this down in prod.
- **ID tokens**: use the Firebase Web SDK on the client; pass `Authorization: Bearer <idToken>` to the backend.

---

## Scripts

- `pnpm dev` – run all apps in dev mode
- `pnpm build` – build all
- `pnpm seed` – seed Firestore with demo data

---

## License

MIT. Enjoy!
