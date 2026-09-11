# VahanOne — Transport Business Operating System & Fleet Management

**VahanOne** is a modern, full-stack multi-tenant SaaS platform built for vehicle owners, commercial fleet operators, and transport agencies. It streamlines fleet compliance (RC, FC, Insurance, Permit, Pollution, Road Tax), driver dispatch, booking lifecycles, invoicing, expense tracking, and profitability analytics.

---

## Architecture Overview

- **Backend**: FastAPI (Python 3.11+), SQLAlchemy 2.0 ORM, Alembic Migrations, Pydantic v2, APScheduler
- **Frontend**: React 18, TypeScript, Vite, Tailwind CSS, Lucide Icons, PWA Support
- **Database & Auth**: PostgreSQL / Supabase, Row-Level Security (RLS) policies, JWT-based RBAC
- **DevOps**: Docker, Docker Compose, GitHub Actions CI/CD Pipeline, Nginx SPA Reverse Proxy

---

## Project Structure

```
vahanone/
├── .github/
│   └── workflows/
│       └── ci.yml               # Automated CI pipeline (lint, test, build)
├── backend/
│   ├── alembic/                 # Database migrations
│   ├── app/
│   │   ├── core/                # App config, dependencies, JWT security
│   │   ├── db/ & models.py      # SQLAlchemy ORM models
│   │   ├── repositories/        # Database query abstractions
│   │   ├── routers/             # FastAPI REST endpoints
│   │   ├── schemas/             # Pydantic validation schemas
│   │   └── services/            # Business logic, profit engine & scheduler
│   ├── docs/                    # Architecture and schema documentation
│   ├── tests/                   # Pytest test suites
│   ├── Dockerfile               # Backend container configuration
│   ├── requirements.txt         # Python dependencies
│   └── .env.example             # Backend environment template
├── frontend/
│   ├── public/                  # PWA assets & manifests
│   ├── src/
│   │   ├── components/          # React components
│   │   ├── hooks/               # Custom React hooks (useAuth, useDashboard)
│   │   ├── lib/                 # API client, Supabase client, helpers
│   │   ├── pages/               # Application view routes
│   │   ├── services/            # Frontend service layer
│   │   └── types/               # TypeScript interfaces
│   ├── Dockerfile               # Frontend multi-stage container build
│   ├── nginx.conf               # Nginx routing configuration
│   └── .env.example             # Frontend environment template
├── supabase/
│   └── migrations/              # SQL migrations and RLS policies
└── docker-compose.yml           # Unified multi-container deployment
```

---

## Quick Start Guide

### Option 1: Running with Docker Compose (Recommended)

To spin up the entire stack (PostgreSQL database, FastAPI backend, and React frontend):

```bash
# 1. Clone the repository
git clone https://github.com/varshikreddy4449-sudo/VahanOne.git
cd VahanOne

# 2. Build and launch all services
docker compose up --build
```

- **Frontend Application**: `http://localhost`
- **FastAPI Backend API**: `http://localhost:8000`
- **Interactive Swagger Docs**: `http://localhost:8000/docs`

---

### Option 2: Local Manual Setup

#### 1. Backend Setup

```bash
cd backend

# Create and activate virtual environment
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment variables
cp .env.example .env
# Edit .env with your PostgreSQL credentials and JWT secret

# Run database migrations
alembic upgrade head

# Start backend server
uvicorn app.main:app --reload --port 8000
```

#### 2. Frontend Setup

```bash
cd frontend

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env
# Edit .env with your API and Supabase details

# Start Vite dev server
npm run dev
```

---

## Core Features

1. **Vehicle & Compliance Management**: Track vehicle specs and Indian statutory renewals (RC, FC, Insurance, Permit, Pollution, Road Tax, EMI due dates).
2. **Driver & Dispatch Management**: License tracking, driver assignment, and availability conflict checking.
3. **Bookings & Calendar**: Booking management supporting hourly, daily, outstation, and package rentals.
4. **Trips & Odometer Execution**: Odometer readings, route logging, and driver allowance records.
5. **Invoicing & Payments**: GST-compliant invoice generation, tax breakdown, advances, and payment tracking.
6. **Expense Tracking & Profit Engine**: Vehicle and trip profitability calculations based on real-time expenses and revenue.
7. **Automated Reminders**: Pre-expiry reminder scheduler (30, 15, and 7-day alerts) for compliance documents.

---

## Testing & CI/CD

- **Backend Pytest**:
  ```bash
  cd backend
  pytest -v
  ```
- **Frontend Type-Check & Build**:
  ```bash
  cd frontend
  npm run build
  ```
- **Continuous Integration**:
  The included GitHub Actions workflow (`.github/workflows/ci.yml`) runs linting, type-checking, backend tests, and frontend build on every push and pull request.
