# SPEC: Ecosystem Support

**Last Updated:** 2026-04-05

---

## Description

Defines tab-aware integration functions for common Vim ecosystem plugins. The plugin already exposes `TabsVim_FzfOpenInTab()` for fzf. This spec extends that pattern to cover vim-flog (git log viewer) and establishes a configurable autocmd for binding `q` → `:tabclose` in ecosystem tool buffers (flog graph, fugitive, vimdiff).

The common workflow: open a tool's output in a dedicated tab, then press `q` to close the whole tab when done — the same mental model as a modal overlay. Without plugin support, users must replicate three separate augroups across their vimrc.

**Persona:** Vim/Neovim users with fzf, vim-flog, and/or vim-fugitive in their setup who open those tools' outputs in tabs.

---

## Features

| Feature | Description | ADR | Done? |
|---------|-------------|-----|-------|
| **`TabsVim_FlogInTab()`** | Open vim-flog git log in a new tab (`Flogsplit -open-cmd=tabedit -all`) | ADR-005 | ⬜ |
| **Ecosystem buffer close** | `g:tabs_vim_tabclose_types` list: buffer types/conditions that get `q` → `:tabclose` auto-wired | ADR-005 | ⬜ |

---

## Public Function API

### Git Integration

| Function | Description |
|----------|-------------|
| `TabsVim_FlogInTab()` | Open vim-flog full-repo git log in a new tab (requires vim-flog) |

### Ecosystem Buffer Close

No function — controlled by config only (see below).

---

## Configuration

### `g:tabs_vim_tabclose_types`

A list of buffer type tokens. For each entry the plugin installs a buffer-local `q` → `:tabclose` mapping. Default is empty (no OOTB behavior).

```vim
" opt-in example — add to vimrc after loading tabs.vim
let g:tabs_vim_tabclose_types = ['floggraph', 'git', 'diff']
```

Supported entry values:

| Value | Trigger condition | Typical source |
|-------|-------------------|----------------|
| `'floggraph'` | `FileType floggraph` | vim-flog graph buffer |
| `'git'` | `FileType git` | vim-fugitive commit/status buffer |
| `'diff'` | `WinEnter` with `&diff` set | vimdiff / `Gdiffsplit` |

Users may pass any valid `FileType` name to cover other tools (e.g. `'fugitiveblame'`).

---

## Recommended vimrc Wiring

```vim
" ── Git log ──────────────────────────────────────────────────────────────────
nnoremap <silent> <leader>gg :call TabsVim_FlogInTab()<CR>

" ── Ecosystem buffer close (q → :tabclose) ───────────────────────────────────
let g:tabs_vim_tabclose_types = ['floggraph', 'git', 'diff']
```

---

## Related

- [key-binding.md](key-binding.md) — full public function API and vimrc wiring reference
- ADR-005 — decision record for this spec
