# Release Pipeline

**Version:** 0.1.0  
**Last Updated:** 2026-04-03  
**Status:** Proposed

---

## Overview

A CI pipeline that publishes clean plugin releases to `main` from a `dev` branch, stripping all development-only files so that `Plug 'jesse23/tabs.vim'` always installs a minimal, user-facing plugin.

---

## Problem Statement

The repo contains two categories of files:

| Category | Files | Should ship to users? |
|----------|-------|-----------------------|
| Plugin | `plugin/`, `autoload/`, `doc/`, `README.md`, `LICENSE` | Yes |
| Dev tooling | `docs/`, `.claude/`, `AGENTS.md`, `CLAUDE.md`, `skills-lock.json` | No |

vim-plug installs via `git clone` from the default branch (`main`). There is no native mechanism to exclude files at clone time. The only way to guarantee users receive only plugin files is to keep `main` clean by construction.

---

## Design

### Branch Model

```
dev  ──── feature branches ──── PRs ──→ dev
                                          │
                                    CI pipeline
                                          │
                                          ▼
                                        main  (plugin files only)
```

- **`dev`** — all development happens here (specs, agent tooling, plugin code)
- **`main`** — managed exclusively by CI; never committed to directly

### Versioning

Versions follow [Semantic Versioning](https://semver.org): `MAJOR.MINOR.PATCH`

| Change type | Version bump |
|-------------|-------------|
| Breaking change to keybindings or public API | MAJOR |
| New feature (new keybinding, new command) | MINOR |
| Bug fix, refactor, cosmetic | PATCH |

Version is the single source of truth in `plugin/tabs.vim`:

```vim
let g:tabs_vim_version = '0.1.0'
```

A release is triggered by bumping this version on `dev`. The pipeline reads the version, creates a Git tag (`v0.1.0`), and publishes to `main`.

### Pipeline Trigger

The CI pipeline runs on every push to `dev`. It only publishes a new release if the version in `plugin/tabs.vim` is higher than the latest Git tag. Non-version-bumping pushes to `dev` (e.g. spec edits) produce no release.

### What Gets Published to `main`

The pipeline copies only:

```
plugin/
autoload/         (if present)
doc/              (if present)
README.md
LICENSE
```

Everything else is excluded.

---

## Implementation

### GitHub Actions Workflow

File: `.github/workflows/release.yml`

Steps:
1. Trigger on push to `dev`
2. Extract version from `plugin/tabs.vim` (`g:tabs_vim_version`)
3. Compare against latest Git tag — skip if version unchanged
4. Checkout `main`, copy plugin files from `dev`, commit, push
5. Create Git tag `vX.Y.Z` on `main`

### Version Bump Workflow (developer)

1. Make changes on `dev` (or a feature branch merged into `dev`)
2. Bump `g:tabs_vim_version` in `plugin/tabs.vim`
3. Push to `dev` — CI handles the rest

---

## Constraints

- `main` is never committed to manually — only the CI bot pushes there
- Version must be bumped intentionally; CI does not auto-increment
- Git tags are immutable — re-releasing the same version is not allowed
