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
- (Optional) **GitHub CLI** for automatic repository creation: `brew install gh` (macOS) or visit [cli.github.com](https://cli.github.com/)

---

## 🚀 Quick Setup (Recommended)

### Option A: Use the Setup Script (Easiest)

We've included an advanced setup script that automates the entire process:

```bash
# Make the script executable
chmod +x setup-new-project.sh

# Run the setup script
./setup-new-project.sh
```

**What the script does automatically:**
- ✅ Detects existing Firebase configuration
- ✅ Creates new GitHub repository (clone) or forks existing one
- ✅ Sets up git remotes correctly
- ✅ Creates all necessary `.env.example` files
- ✅ Installs dependencies
- ✅ Updates package.json with new project name
- ✅ Provides step-by-step guidance

**Setup script features:**
- **Clone vs Fork choice**: Create new repo or maintain connection to original
- **Smart Firebase detection**: Automatically finds and extracts config values
- **Interactive prompts**: Guided setup with validation
- **Automatic dependency installation**: Uses pnpm/yarn/npm based on availability
- **Environment file creation**: Pre-fills with detected values when possible

### Option B: Manual Setup

If you prefer to set up manually, continue to the next section.

---

## 📋 Setup Script Workflow

When you run `./setup-new-project.sh`, here's what happens:

### 1. **Project Setup Method Selection**
```
Choose your project setup method:
1) Clone from starter pack (creates new repository)
2) Fork from starter pack (keeps connection to original)
```

**Clone (Recommended for new projects):**
- Creates completely new repository
- Removes git history from starter pack
- Perfect for starting fresh projects

**Fork:**
- Maintains connection to original repository
- Good for contributing back or keeping updates

### 2. **Project Information Collection**
- GitHub username
- Starter pack repository name
- New project name and description
- Local directory name
- Repository visibility (private/public/internal)

### 3. **Firebase Configuration**
The script automatically detects Firebase config files:
- `firebase.json`
- `.firebaserc`
- `firebase.config.js`
- `firebase.config.json`

**Configuration options:**
- Use detected configuration (auto-extracts project ID, storage bucket)
- Enter configuration manually
- Skip Firebase configuration

### 4. **Automatic Setup Steps**
- Repository creation (GitHub CLI or manual instructions)
- Git remote configuration
- Package.json updates
- Environment file creation
- Dependency installation
- Firebase config cleanup (optional)

### 5. **Final Output**
- New project directory created
- All `.env.example` files ready
- Dependencies installed
- Clear next steps provided

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

## 🔧 Setup Script Troubleshooting

### **Prerequisites Issues**
```bash
# If Git is not found
brew install git  # macOS
# or visit: https://git-scm.com/

# If GitHub CLI is not found
brew install gh   # macOS
# or visit: https://cli.github.com/

# If jq is not found (for Firebase config parsing)
brew install jq   # macOS
# or visit: https://stedolan.github.io/jq/
```

### **Common Script Issues**
- **Permission denied**: Run `chmod +x setup-new-project.sh`
- **Directory already exists**: Script will ask to remove or choose different name
- **GitHub CLI authentication**: Run `gh auth login` before using the script
- **Firebase config not detected**: Check if config files exist in project root

### **Manual Fallback**
If the script fails, you can always:
1. Clone manually: `git clone <your-starter-repo> <new-project-name>`
2. Create repository on GitHub manually
3. Follow the manual setup steps below

### **Environment Variables**
After running the script, you'll have:
- `apps/web/.env.example` → Copy to `apps/web/.env.local`
- `apps/api/.env.example` → Copy to `apps/api/.env`
- `.env.example` → Copy to `.env`

Fill in your actual values in these files.

---

## Scripts

- `pnpm dev` – run all apps in dev mode
- `pnpm build` – build all
- `pnpm seed` – seed Firestore with demo data

---

## 🚀 Quick Start Commands

**For immediate setup:**
```bash
# Make script executable and run
chmod +x setup-new-project.sh && ./setup-new-project.sh

# Or run manually
chmod +x setup-new-project.sh
./setup-new-project.sh
```

**After setup:**
```bash
# Navigate to your new project
cd <your-new-project-name>

# Install dependencies (if not already done)
pnpm install

# Start development
pnpm dev
```

---

## License

MIT. Enjoy!
