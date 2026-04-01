# Kontra iOS

Native iOS app for the **Kontra Loan Servicing Platform** — a fully AI-native workspace for multifamily and CRE loan management.

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9+ |
| UI | SwiftUI |
| Architecture | MVVM + async/await |
| Min iOS | iOS 17.0 |
| Auth | JWT via Supabase, stored in Keychain |
| API | `https://kontra-api.onrender.com` |

## Modules

| Tab | Features |
|---|---|
| **Dashboard** | Portfolio summary stats, recent loans, pools, AI flags |
| **Portfolio** | Loans (amount, rate, term), Assets |
| **Servicing** | Payments, Inspections, Draws, Escrows, Borrower Financials, Management |
| **Governance** | Compliance, Risk, Legal Items, Document Reviews, Regulatory Scans, AI Insights |
| **Markets** | Pools (with tokenization), Tokens, Exchange Listings, Reports |

## Getting Started

```bash
# Clone
git clone https://github.com/gamilsaad92/kontra-ios.git
cd kontra-ios

# Open in Xcode 15+
open KontraApp.xcodeproj
```

Select any simulator or device, then build and run (⌘R).

## Authentication

Sign in with your Kontra platform credentials (same as the web app at [kontraplatform.com](https://kontraplatform.com)).

The app uses Supabase JWT auth. Tokens are stored securely in the iOS Keychain and injected into every API request as `Authorization: Bearer <token>` alongside `X-Org-Id`.

## Architecture

```
KontraApp/
├── Core/
│   ├── Network/        # APIClient (URLSession), APIModels (Codable)
│   ├── Auth/           # AuthManager (@MainActor singleton), KeychainHelper
│   └── Theme/          # KontraTheme (colors, badges, cards)
├── Features/
│   ├── Login/          # LoginView — email/password Supabase auth
│   ├── Main/           # MainTabView — 5-tab navigation
│   ├── Dashboard/      # DashboardView + ViewModel — summary + recents
│   ├── Portfolio/      # LoansView, AssetsView, LoanDetailView
│   ├── Servicing/      # ServicingView + EntityListPage per resource
│   ├── Governance/     # GovernanceView + EntityListPage per resource
│   ├── Markets/        # MarketsView, PoolsView, PoolDetailView
│   ├── AI/             # AIInsightsView + filter by status
│   └── Settings/       # SettingsView — account info + sign out
└── Shared/
    ├── Components/     # EntityListView (generic), CreateEntitySheet
    └── Extensions/     # Date+Extensions
```

## API Contract

All data flows through the Kontra REST API:

- `POST /api/auth/signin` — login, returns `access_token`
- `GET  /api/{module}/{resource}` — returns `{ items: [...], total: N }`
- `POST /api/{module}/{resource}` — creates with `{ title, status, data }`
- `PATCH /api/{module}/{resource}/:id` — partial update
- `DELETE /api/{module}/{resource}/:id` — soft delete

Modules: `portfolio`, `servicing`, `governance`, `markets`, `ai`, `reports`

Resources per module match the web platform's navigation structure exactly.

## Multi-tenant RLS

Each request sends `X-Org-Id` (raw integer org ID extracted from the JWT) which the API converts to the UUID format `00000000-0000-0000-0000-{12-digit-padded}` for Supabase RLS enforcement. No client-side UUID conversion needed.

## Contributing

Pull requests welcome. Please match the existing SwiftUI + MVVM patterns and use `async/await` for all networking.
