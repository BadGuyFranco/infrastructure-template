# Documentation Congruence Check

**Trigger:** Referenced by other checklists when documentation consistency must be verified.
**Persona:** Shared

## Steps

1. **ARCHITECTURE.md currency.** Every component touched has an accurate ARCHITECTURE.md with updated verification stamps (last-verified date = today). Maturity tags match actual code state.
2. **BUILD_STATUS.md currency.** Every component touched has an updated build status entry reflecting the work done.
3. **Living docs alignment.** ADRs, CODE_STANDARDS -- all consistent with actual code. No drift between what docs say and what code does.
4. **AGENTS.md routing tables.** For every directory touched this session, verify the AGENTS.md routing table matches actual contents. Entries must resolve to files/directories that exist. New files or modules must appear in the table. Deleted or moved items must be removed or updated. If a directory you touched has no AGENTS.md and it is a work-target directory (service package, feature module, infrastructure directory), flag the gap.

## Gate

All living docs match current code state. Verification stamps current. AGENTS.md routing current for all touched directories. No drift detected.
