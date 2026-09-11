# VahanOne — Cloud Production Deployment Guide

This guide details the step-by-step production deployment of **VahanOne**:
- **Database, Auth & Storage**: Supabase
- **Backend API & Reminder Scheduler**: Render / Railway
- **Frontend SPA Application**: Vercel

---

## Step 1: Database, Auth & Storage Setup (Supabase)

1. Go to [Supabase](https://supabase.com/) and create a new project.
2. In the Supabase dashboard, navigate to **SQL Editor**.
3. Execute the SQL migration scripts located in `supabase/migrations/` in the following numerical sequence:
   1. `20260610161215_001_initial_schema.sql`
   2. `20260610161252_002_rls_policies.sql`
   3. `20260610161307_003_seed_data.sql`
   4. `20260610161840_004_sample_data.sql`
   5. `20260611101909_005_anon_rls_policies.sql`
   6. `20260619095059_add_vehicle_document_settings_tables.sql`
   7. `20260619095733_add_sample_data.sql`
   8. `20260619100933_20260619120000_fix_rls_security.sql.sql`
4. Under **Storage**, create a new bucket named `documents` (set to Public or Authenticated).
5. Navigate to **Project Settings > API** and copy:
   - **Project URL** (e.g., `https://xyzcompany.supabase.co`)
   - **`anon` `public` key**
6. Navigate to **Project Settings > Database** and copy the **Connection string (URI)**.

---

## Step 2: Backend API Deployment (Render / Railway)

### Option A: Render Blueprint (Infrastructure-as-Code)
1. Push this repository to your GitHub account (`https://github.com/varshikreddy4449-sudo/VahanOne`).
2. Log into [Render](https://render.com/).
3. Click **New + > Blueprint** and connect your repository.
4. Render will detect `render.yaml` and automatically configure the PostgreSQL database and FastAPI service.
5. Once deployed, copy your backend URL (e.g., `https://vahanone-backend.onrender.com`).

### Option B: Render Manual Web Service
1. Click **New + > Web Service**.
2. Connect your repo and set:
   - **Root Directory**: `backend`
   - **Runtime**: `Python 3`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
3. Add Environment Variables:
   - `DATABASE_URL`: `postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres` (Supabase DB URI)
   - `JWT_SECRET_KEY`: `<Generate a secure 32+ character random string>`
   - `JWT_ALGORITHM`: `HS256`
   - `ACCESS_TOKEN_EXPIRE_MINUTES`: `60`
   - `ENABLE_REMINDER_SCHEDULER`: `true`

---

## Step 3: Frontend Deployment (Vercel)

1. Log into [Vercel](https://vercel.com/) and click **Add New > Project**.
2. Select your repository `VahanOne`.
3. In the project configuration:
   - **Framework Preset**: `Vite`
   - **Root Directory**: Click `Edit` and select `frontend`
4. Expand **Environment Variables** and add:
   | Variable | Value |
   | :--- | :--- |
   | `VITE_API_BASE_URL` | `https://vahanone-backend.onrender.com` (Your backend URL) |
   | `VITE_SUPABASE_URL` | `https://xyzcompany.supabase.co` |
   | `VITE_SUPABASE_ANON_KEY` | `your_supabase_anon_key` |
5. Click **Deploy**.

---

## Step 4: Verification & Smoke Test

1. Open your Vercel frontend URL.
2. Sign in or create a new user account.
3. Test adding a vehicle in **Vehicles** and verify compliance dates.
4. Verify backend Swagger documentation at `https://vahanone-backend.onrender.com/docs`.
