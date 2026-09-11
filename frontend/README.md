# VahanOne - Fleet Management Platform

A production-ready SaaS web application for vehicle management and reminder platform for vehicle owners, fleet operators, and transport companies.

## Features

- **Authentication**: Email/Password and Google OAuth login
- **Dashboard**: Overview of vehicles, expiring documents, upcoming renewals, active drivers, expenses, and profit
- **Vehicle Management**: Complete CRUD with compliance tracking (RC, Insurance, Permit, FC, Pollution, Road Tax)
- **Driver Management**: Track drivers, licenses, and assignments
- **Document Management**: Upload and manage vehicle documents with Supabase Storage
- **Expense Tracking**: Track fuel, maintenance, EMI, insurance, and other expenses
- **Reports**: Vehicle-wise, expense, and renewal reports
- **Reminder System**: Notifications for upcoming renewals (30/15/7 days before)
- **Settings**: Company profile, bank details, and invoice configuration

## Tech Stack

- **Frontend**: React 18, TypeScript, Vite, Tailwind CSS
- **Backend**: Supabase (PostgreSQL, Auth, Storage)
- **UI**: Mobile-first responsive design
- **PWA**: Progressive Web App support

## Getting Started

### Prerequisites

- Node.js 18+
- Supabase account
- Google OAuth credentials (optional)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd vahanone/frontend
npm install
```

2. Create a `.env` file based on `.env.example`:
```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

3. Start the development server:
```bash
npm run dev
```

### Supabase Setup

1. Create a new Supabase project
2. Run the migrations from `supabase/migrations/` in order
3. Enable Google OAuth in Authentication > Providers (optional)
4. Create a storage bucket named `documents`

### Database Schema

The application uses the following tables:
- `organizations` - Multi-tenant organization data
- `users` - User accounts
- `user_profiles` - Extended user profile data
- `vehicles` - Vehicle fleet data
- `drivers` - Driver information
- `documents` - Uploaded documents
- `bookings` - Booking/reservation records
- `trips` - Trip records
- `expenses` - Expense tracking
- `invoices` - Invoice management
- `company_settings` - Company profile settings
- `reminders` - Reminder/notification data

## Deployment on Vercel

### Method 1: Vercel CLI

```bash
npm install -g vercel
vercel
```

### Method 2: Vercel Dashboard

1. Push code to GitHub
2. Import repository in Vercel dashboard
3. Set environment variables:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
4. Deploy

### Environment Variables

Set these in Vercel dashboard under Settings > Environment Variables:

| Variable | Description |
|----------|-------------|
| `VITE_SUPABASE_URL` | Your Supabase project URL |
| `VITE_SUPABASE_ANON_KEY` | Your Supabase anon/public key |

## Project Structure

```
frontend/
├── public/
│   ├── manifest.json      # PWA manifest
│   ├── sw.js              # Service worker
│   └── favicon.svg        # App icon
├── src/
│   ├── components/
│   │   ├── drivers/       # Driver-related components
│   │   ├── layout/        # Layout components (Header, Sidebar, ProtectedRoute)
│   │   ├── notifications/ # Notification components
│   │   ├── ui/            # Reusable UI components (Button, Card, Input)
│   │   └── vehicles/      # Vehicle-related components
│   ├── hooks/
│   │   ├── useAuth.ts     # Authentication hook
│   │   └── useDashboard.ts # Dashboard data hook
│   ├── lib/
│   │   ├── api.ts         # API utilities
│   │   ├── supabase.ts    # Supabase client
│   │   └── transformers.ts # Data transformers
│   ├── pages/
│   │   ├── Dashboard.tsx
│   │   ├── Vehicles.tsx
│   │   ├── Drivers.tsx
│   │   ├── Documents.tsx
│   │   ├── Settings.tsx
│   │   ├── Reports.tsx
│   │   └── ... other pages
│   ├── services/
│   │   ├── authService.ts
│   │   ├── vehicleService.ts
│   │   ├── driverService.ts
│   │   ├── documentService.ts
│   │   └── ... other services
│   ├── types/
│   │   └── index.ts       # TypeScript types
│   └── App.tsx            # Main app with routing
└── package.json
```

## User Roles

- **Admin**: Full access to all features
- **Fleet Owner**: Manage own fleet and drivers
- **Vehicle Owner**: Manage own vehicles

## Features Details

### Authentication Flow

1. Email/Password signup with email verification
2. Google OAuth for quick signup/signin
3. Password reset via email
4. Session persistence with automatic token refresh

### Document Management

- Upload RC, Insurance, Permit, FC, Pollution certificates
- Preview documents in browser
- Download documents
- Track expiry dates with reminders

### Reminder System

- Automatic reminders for:
  - Vehicle document renewals (30, 15, 7 days before expiry)
  - License renewals
  - EMI due dates
  - Service due dates

### Mobile Responsive

- Touch-friendly navigation drawer
- Responsive tables with horizontal scroll
- Mobile-optimized forms and cards

## License

MIT License
