# Agent Guide

This is `tabs.vim` — a Vim plugin for managing tabs efficiently.

## Development Workflow

Follow [docs/development.md](docs/development.md) — Spec & ADR Driven Development. Every change starts with a SPEC and ADR before implementation.

## Repo Structure

```
tabs.vim/
├── docs/
│   ├── specs/                   # living architecture specs
│   ├── adrs/                    # architecture decision records
│   └── development.md           # how to use specs and ADRs
└── README.md
```

## Rules

- **Match existing patterns** — read 2-3 similar files before writing new ones.
- **Don't create docs unprompted** — no SPECs or ADRs unless the work warrants one.
- **Pin dependencies** — no `^` or `~` ranges. Exact versions only.
