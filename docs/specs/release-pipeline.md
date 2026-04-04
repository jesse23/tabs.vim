# Release Pipeline

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

No explicit version is maintained. vim-plug pins installs by commit hash and users run `:PlugUpdate` to move forward. This is sufficient for a plugin of this scope.

### Pipeline Trigger

The CI pipeline runs on every push to `dev` and unconditionally publishes to `main`.

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
2. Checkout `main`, copy plugin files from `dev`, commit, push

### Developer Workflow

1. Make changes on `dev` (or a feature branch merged into `dev`)
2. Push to `dev` — CI publishes to `main` automatically

---

## Constraints

- `main` is never committed to manually — only the CI bot pushes there
