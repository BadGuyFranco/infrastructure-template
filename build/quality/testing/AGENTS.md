# Testing

{PROJECT_NAME}'s test infrastructure. All test layers (unit, contract, integration, E2E, scenario, production monitoring) are defined and managed here.

## Routing

- **Test strategy, layers, and infrastructure?** -> [ARCHITECTURE.md](ARCHITECTURE.md)
- **Test accounts, credentials, auth IDs, connection details?** -> [TEST_ACCOUNTS.md](TEST_ACCOUNTS.md) (create when needed)

## Rules

- Read TEST_ACCOUNTS.md before running any test that requires authentication, database access, or a staging/production target.
- Read ARCHITECTURE.md before adding new tests -- it defines which layer a test belongs to and what patterns to follow.
