# {PROJECT_NAME} -- Dependencies

This document lists the opinionated stack and required tooling for {PROJECT_NAME}. All team members and CI environments must have these installed.

---

## Required Runtime & Tooling

| Tool | Version | Purpose | Verify |
|------|---------|---------|--------|
| **Node.js** | 20+ (LTS) | JavaScript runtime | `node --version` |
| **pnpm** | 9+ | Package manager with workspace support | `pnpm --version` |
| **TypeScript** | 5.4+ | Language (installed per-workspace) | `pnpm exec tsc --version` |
| **Git** | 2.40+ | Version control | `git --version` |
| **GitHub CLI** | 2.40+ | PR creation, issue management, CI checks | `gh --version` |
| **tmux** | 3.3+ | Multi-agent session management (Oscar/Bob) | `tmux -V` |

## Required Infrastructure

| Service | Purpose | Verify |
|---------|---------|--------|
| **Neon PostgreSQL** | Primary database (serverless Postgres) | `psql "{NEON_CONNECTION_STRING}" -c "SELECT 1"` |
| **GCP (Cloud Run)** | Application hosting | `gcloud run services list --project={GCP_PROJECT_ID} --region={GCP_REGION}` |
| **GCP (Cloud Storage)** | File storage, backups | `gcloud storage ls --project={GCP_PROJECT_ID}` |
| **BetterAuth** | Authentication (self-hosted) | Verify auth routes respond at `{API_STAGING_URL}/api/auth` |

## Optional Infrastructure

| Service | Purpose | When Needed | Verify |
|---------|---------|-------------|--------|
| **Stripe** | Payment processing, subscriptions | If billing is enabled | `curl -s https://api.stripe.com/v1/prices -H "Authorization: Bearer $STRIPE_SECRET_KEY" \| head -1` |

## Development Libraries

These are installed via `pnpm install` and do not need manual installation:

| Library | Purpose | Where Alternatives Slot In |
|---------|---------|---------------------------|
| **Vitest** | Unit + integration testing | Could swap for Jest, but Vitest is preferred for its speed and native ESM support |
| **ESLint** | Linting (flat config) | Standard; no realistic alternative needed |
| **Turborepo** | Monorepo build orchestration | Could swap for Nx, but Turborepo is simpler for pnpm workspaces |
| **tRPC** | End-to-end type-safe APIs | Could swap for REST + OpenAPI codegen if non-TypeScript clients are needed |
| **Drizzle ORM** | Database queries and migrations | Could swap for Prisma or Kysely; Drizzle chosen for SQL-closeness and performance |
| **Zod** | Runtime schema validation | Could swap for Valibot or ArkType; Zod has the broadest ecosystem integration |

## Environment Variables

Environment-specific configuration is stored in `.env` files. These are never committed to the repository.

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | Neon PostgreSQL connection string | Yes |
| `GCP_PROJECT_ID` | Google Cloud project ID | Yes (deployment) |
| `GCP_REGION` | Google Cloud region (e.g., `us-central1`) | Yes (deployment) |
| `BETTER_AUTH_SECRET` | BetterAuth signing secret | Yes |
| `STRIPE_SECRET_KEY` | Stripe API key | If billing enabled |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signing secret | If billing enabled |

## Quick Setup

```bash
# 1. Install Node.js 20+ (via nvm, fnm, or direct download)
nvm install 20 && nvm use 20

# 2. Install pnpm
corepack enable && corepack prepare pnpm@latest --activate

# 3. Install dependencies
pnpm install

# 4. Verify the stack
node --version        # v20.x.x+
pnpm --version        # 9.x.x+
git --version         # 2.40+
gh --version          # 2.40+
tmux -V               # tmux 3.3+

# 5. Run typecheck + tests
pnpm turbo run typecheck
pnpm turbo run test
```

## Where Alternatives Slot In

The stack is opinionated but not locked. When substituting a component:

| If you swap... | Update these files |
|----------------|--------------------|
| Neon PostgreSQL -> Supabase/PlanetScale | `DEPENDENCIES.md`, `ARCHITECTURE.md`, all `DATABASE_URL` references, ORM config |
| GCP -> AWS/Vercel | `DEPENDENCIES.md`, `ARCHITECTURE.md`, deployment scripts, CI/CD workflows |
| BetterAuth -> Clerk/Auth.js | `DEPENDENCIES.md`, `ARCHITECTURE.md`, auth ADR, services auth module |
| Stripe -> Paddle/Lemon Squeezy | `DEPENDENCIES.md`, `ARCHITECTURE.md`, billing ADR, services billing module |
| Vitest -> Jest | `DEPENDENCIES.md`, all `vitest.config.ts` files, test imports |
| Drizzle -> Prisma | `DEPENDENCIES.md`, `ARCHITECTURE.md`, schema files, migration scripts |
