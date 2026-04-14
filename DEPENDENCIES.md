# {PROJECT_NAME} -- Dependencies

This document lists the required tooling for {PROJECT_NAME} and provides an example stack. Customize the infrastructure and library sections for your project.

## Required Runtime and Tooling

| Tool | Version | Purpose | Verify |
|------|---------|---------|--------|
| **Node.js** | 20+ (LTS) | JavaScript runtime | `node --version` |
| **pnpm** | 10+ | Package manager with workspace support | `pnpm --version` |
| **TypeScript** | 5.4+ | Language (installed per-workspace) | `pnpm exec tsc --version` |
| **Git** | 2.40+ | Version control | `git --version` |
| **GitHub CLI** | 2.40+ | PR creation, issue management, CI checks | `gh --version` |
| **tmux** | 3.3+ | Multi-agent session management (Oscar/Bob) | `tmux -V` |

## Infrastructure (Example -- Replace for Your Project)

<!-- Replace this section with your actual infrastructure. The table below
     is an example showing the level of detail to include. -->

| Service | Purpose | Verify |
|---------|---------|--------|
| **PostgreSQL** (e.g., Neon, Supabase, RDS) | Primary database | `psql "$DATABASE_URL" -c "SELECT 1"` |
| **Cloud hosting** (e.g., GCP Cloud Run, AWS ECS, Vercel) | Application hosting | Platform-specific health check |
| **Object storage** (e.g., GCS, S3, R2) | File storage, backups | Platform-specific list command |

## Development Libraries (Example -- Replace for Your Project)

<!-- These are installed via `pnpm install` and do not need manual installation.
     Document your actual library choices here. -->

| Library | Purpose | Alternatives |
|---------|---------|-------------|
| **Vitest** | Unit + integration testing | Jest, Bun test |
| **ESLint** | Linting (flat config) | Biome |
| **Turborepo** | Monorepo build orchestration | Nx, Lerna |

## Environment Variables

Environment-specific configuration is stored in `.env` files. These are never committed to the repository.

<!-- Replace with your actual required environment variables. -->

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | Database connection string | Yes |

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
pnpm --version        # 10.x.x+
git --version         # 2.40+
gh --version          # 2.40+
tmux -V               # tmux 3.3+

# 5. Run typecheck + tests
pnpm turbo run typecheck
pnpm turbo run test
```
