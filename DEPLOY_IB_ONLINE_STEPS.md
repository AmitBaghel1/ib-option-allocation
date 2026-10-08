# 🚀 Deploy IB Option Allocation online (Vercel + Render) — step by step

You chose **Vercel (Next.js frontend) + Render (FastAPI backend)**.
This gives you two permanent public URLs. Total time: ~20 min, all free tier.

Your repo is already prepared:
- `frontend/vercel.json` — Vercel settings (Root Directory = `frontend`)
- `frontend/next.config.js` — proxies `/api/*` to `BACKEND_URL`, no CORS setup needed
- `render.yaml` — Render blueprint (not needed for this path, only for Render+Render)
- `backend/requirements.txt` — pinned deps, tests green (37 passed per DEPLOYMENT.md)
- `.gitignore` — excludes `*.db`, `.venv/`, `.next/`, `.env`, secrets ✅
- `backend/app/seed.py` — seeds demo data (admin/admin123) on first deploy

---

## STEP 1 — Create the GitHub repo (5 min, on github.com)

1. Go to **https://github.com/new**
2. **Repository name:** `ib-option-allocation` (or any name)
3. Visibility: **Private** is fine (Vercel/Render can read private repos after you authorize GitHub)
4. ⚠️ Do NOT tick "Add a README", "Add .gitignore", or "Choose a license" — your code is already committed locally
5. Click **Create repository**
6. GitHub shows you a URL like `https://github.com/YOUR-USERNAME/ib-option-allocation.git` — **copy it**, you need it in Step 2

> No `gh` CLI or git install needed — your machine already has git at
> `C:\Program Files\Git\cmd\git.exe`, and the project is committed on branch `main`.

## STEP 2 — Push your code (2 min, in PowerShell)

Open PowerShell and run (pushes ONLY the IB folder using subtree split):

```powershell
$g = 'C:\Program Files\Git\cmd\git.exe'
cd 'C:\Users\abagh\.cline\data\workspaces\chat\school-ai\school-ai-analytics-ib-option-allocation'
& $g remote add origin https://github.com/AmitBaghel1/ib-option-allocation.git
& $g subtree push --prefix=ib-option-allocation origin main
```

> The repo root on your disk contains a second app (School AI platform), so we push
> only the `ib-option-allocation/` prefix. Vercel/Render will then see `frontend/`,
> `backend/`, `render.yaml` at the repo root — exactly what they expect.
- GitHub asks for a password → use a **Personal Access Token**, not your login password:
  GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
  → Generate → tick `repo` → copy the `ghp_...` token → paste as password.
- Verify: refresh your GitHub repo page — you should see `frontend/`, `backend/`, `render.yaml`, etc.

## STEP 3 — Deploy the backend on Render (7 min)

1. Go to **https://dashboard.render.com** → sign up/in (GitHub button is easiest)
2. **New → Web Service** → **Build and deploy from a Git repository** → connect/select your repo
3. Fill in **exactly**:
   | Field | Value |
   |---|---|
   | Name | `ib-allocation-api` |
   | Root Directory | `backend` |
   | Runtime | `Python 3` |
   | Build Command | `pip install -r requirements.txt && python -m alembic upgrade head && python -m app.seed` |
   | Start Command | `python -m uvicorn app.main:app --host 0.0.0.0 --port $PORT` |
   | Instance Type | `Free` |
4. **Environment Variables → Add:**
   - `SECRET_KEY` → any long random string (e.g. generate at https://generate-secret.vercel.app/32)
   - `CORS_ORIGINS` → `*` (safe here because the browser only talks to Vercel, which proxies server-side)
   - `PYTHON_VERSION` → `3.12`
5. Click **Create Web Service**. First build takes ~3–5 min.
6. When it says **Live**, open `https://ib-allocation-api.onrender.com/api/health`
   → you must see `{"status":"ok"}`. **Copy this URL** — you need it for Vercel.
   - Logins are seeded: `admin/admin123`, `viewer/viewer123`.

> 📝 Free Render sleeps after 15 min idle (first request wakes it in ~50 s) and the SQLite
> file resets on restart. Fine for a demo. For permanent school data, add a free Render
> PostgreSQL instance later and set `DATABASE_URL=postgresql+psycopg2://...` on the API
> service (also uncomment `psycopg2-binary` in `backend/requirements.txt`).

## STEP 4 — Deploy the frontend on Vercel (5 min)

1. Go to **https://vercel.com** → sign up/in with GitHub
2. **Add New → Project** → Import your repo
3. On the Configure page set **exactly**:
   | Field | Value |
   |---|---|
   | Framework Preset | `Next.js` (auto-detected) |
   | Root Directory | `frontend` ← click Edit and select it |
   | Build Command | `npm run build` (default) |
   | Output Directory | (leave default) |
4. **Environment Variables** → add:
   - `BACKEND_URL` = `https://ib-allocation-api.onrender.com` (your URL from Step 3 — no trailing slash)
5. Click **Deploy**. Build takes ~2 min.
6. You get `https://ib-option-allocation-xxx.vercel.app` — open it, log in with `admin/admin123`.
   Every page (`/allocations`, `/import`, `/reports`...) calls `/api/*`, which Vercel rewrites
   to your Render backend (see `frontend/next.config.js`), so there are no CORS errors.

## STEP 5 — Verify end-to-end ✅

- [ ] `https://YOUR-API.onrender.com/api/health` → `{"status":"ok"}`
- [ ] `https://YOUR-APP.vercel.app/login` → log in `admin/admin123` works
- [ ] Import a CSV (use `sample_csv/students.csv`) → rows appear
- [ ] Run an allocation → results show; create a change request → feasibility badge shows

## If something fails

| Symptom | Fix |
|---|---|
| Render build: `ResolutionImpossible` / starlette clash | Don't downgrade FastAPI — repo already pins `fastapi>=0.142` which is compatible with Streamlit's starlette. Just hit Manual Deploy |
| Vercel: `404` on `/api/*` | `BACKEND_URL` missing/wrong, or Root Directory isn't `frontend`. Fix → Redeploy |
| Vercel page loads but "fetch failed" | Render free instance is asleep — open the `/api/health` URL once to wake it, then reload Vercel |
| `Attempted to load @next/swc-...` locally | `npm install next@14.2.33 @next/swc-win32-x64-msvc@14.2.33` in `frontend/` (pinned pair) |

## Your current temporary URLs (still working)

- School Knowledge AI: https://assist-lip-introduction-scotia.trycloudflare.com (local :3000)
- IB app (tunnel): https://euro-spring-displayed-strain.trycloudflare.com (local :3001 + :8001)
- These die when your laptop sleeps — the Vercel+Render URLs above are the permanent fix.
