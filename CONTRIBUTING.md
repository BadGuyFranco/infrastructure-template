# Contributing

Thank you for your interest in improving the Infrastructure Template.

## How to Contribute

### Bug Reports

If you find a broken reference, a script that doesn't work, or a placeholder that setup.sh misses, [open an issue](https://github.com/BadGuyFranco/infrastructure-template/issues/new?template=bug_report.md).

### Improvements

1. Fork the repo
2. Create a branch (`git checkout -b improve-xyz`)
3. Make your changes
4. Run the validation: `./setup.sh --check` should still work correctly
5. Open a pull request

### What Makes a Good Contribution

- **Fixes that help first-time users.** If you got stuck following QUICKSTART.md, fix the step that confused you.
- **New checklists** for common workflow moments (CI/CD, database migrations, dependency updates).
- **New `.claude/rules/`** for common tech stacks (Python, Go, React, etc.).
- **Platform support** for Linux or WSL (tmux path updates, terminal emulator alternatives).

### What We Won't Merge

- Project-specific content. The template must stay generic.
- Opinionated tech stack choices. Examples are fine; requirements are not.
- Changes that break `setup.sh --check` or the CI workflow.

## Code of Conduct

Be respectful. File issues with reproduction steps. Review others' PRs when you can.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
