# SPEC: Ecosystem Support

**Last Updated:** 2026-04-06

---

## Description

Defines how `tabs.vim` integrates with common Vim ecosystem plugins. The plugin does **not** wrap third-party plugin functions — those one-liner wrappers belong in the user's vimrc and are documented here as recipes. The one plugin-side feature is `g:tabs_vim_tabclose_types`, which wires `q` → `:tabclose` for specified buffer types.

**Persona:** Vim/Neovim users with fzf, vim-flog, and/or vim-fugitive who open those tools' outputs in dedicated tabs.

---

## Design Boundary

Third-party integrations (fzf, vim-flog, vimdiff) are **not wrapped** by tabs.vim. Wrapping them introduces undeclared optional dependencies and couples the plugin to unrelated workflows. The integration is instead documented as vimrc recipes — one-line mappings the user owns directly.

---

## Features

| Feature | Description | ADR | Done? |
|---------|-------------|-----|-------|
| **Ecosystem buffer close** | `g:tabs_vim_tabclose_types` list: buffer types that get `q` → `:tabclose` auto-wired | ADR-005 | ✅ |

---

## Configuration

### `g:tabs_vim_tabclose_types`

A list of buffer type tokens. For each entry the plugin installs a buffer-local `q` → `:tabclose` mapping. Default is empty (no OOTB behavior).

```vim
" opt-in example — must be set before the plugin loads (i.e. before plug#end())
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

## Vimrc Recipes

These are direct calls — no plugin wrapper needed.

### fzf.vim: open file picker in a new tab

```vim
" Requires: junegunn/fzf + junegunn/fzf.vim
nnoremap <silent> <leader>ft :call fzf#vim#files('', fzf#vim#with_preview({'sink': 'tabedit'}), 0)<CR>
```

### vim-flog: open git log in a new tab

```vim
" Requires: rbong/vim-flog
nnoremap <silent> <leader>gg :Flogsplit -open-cmd=tabedit -all<CR>
```

### Full ecosystem wiring block

```vim
" ── Ecosystem integrations ────────────────────────────────────────────────────
nnoremap <silent> <leader>ft :call fzf#vim#files('', fzf#vim#with_preview({'sink': 'tabedit'}), 0)<CR>
nnoremap <silent> <leader>gg :Flogsplit -open-cmd=tabedit -all<CR>

" ── Ecosystem buffer close (q → :tabclose) ───────────────────────────────────
" Must be set before plug#end() — read once at plugin load time.
let g:tabs_vim_tabclose_types = ['floggraph', 'git', 'diff']
```

---

## Related

- [key-binding.md](key-binding.md) — full public function API and vimrc wiring reference
- ADR-005 — decision record for this spec
