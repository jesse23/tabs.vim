# SPEC: Key Binding

**Last Updated:** 2026-04-04

---

## Description

Defines the keybinding contract for `tabs.vim`: what the plugin installs out-of-the-box (OOTB), what public functions it exposes for users to bind themselves, and the recommended vimrc wiring pattern.

The plugin intentionally keeps OOTB bindings minimal to avoid conflicts with user keymaps and other plugins. All operations are exposed as stable `TabsVim_*` public functions. Users adopt the ones they want and bind them to their preferred keys.

**Persona:** Vim/Neovim users who want tab-management features without the plugin imposing a full keymap.

---

## OOTB Behavior

The plugin installs **no keybindings** by default. Tab navigation is already covered by Vim natively (`gt` / `gT` / `<count>gt`).

The one OOTB behavior is **mouse drag-and-drop file opening**: dropping a file from a file manager into the terminal opens it in a new tab. This is implemented via bracketed-paste terminal sequences (`t_BE`/`t_BD`) and synthetic key aliases (`<F30>`/`<F31>`), which require infrastructure the user cannot set up from a plain vimrc mapping. It activates only in terminal Vim (not GVim) on Vim 8.0.0210+.

---

## Public Function API

Only operations with real logic are exposed as `TabsVim_*` functions. Simple one-liner native commands (`:tabnew`, `:sp`, `:tabonly`, `:only`, `:tabedit <cfile>`, `let @+ = expand("%:p")`) are documented as direct vimrc mappings below — no wrapper needed.

### Terminal Operations

| Function | Description |
|----------|-------------|
| `TabsVim_ToggleHorizTerm()` | Toggle a persistent horizontal split terminal (below, 15 rows) |
| `TabsVim_ToggleVertTerm()` | Toggle a persistent vertical split terminal (right, 80 cols) |
| `TabsVim_NewTabTerm()` | Open a new terminal in its own tab |

### Window / Buffer Operations

| Function | Description |
|----------|-------------|
| `TabsVim_CloseOrHide()` | Close the current window; if last window, prompt to quit Vim; if a terminal buffer, toggle-hide it instead |
| `TabsVim_RenameBuffer()` | Prompt to rename the current buffer |

### FZF Integration

| Function | Description |
|----------|-------------|
| `TabsVim_FzfOpenInTab()` | Open fzf file picker with `tabedit` as the sink (requires fzf.vim) |

---

## Recommended vimrc Wiring

Copy and adapt the block below. Remove any line you don't use.

```vim
" ── Tab navigation ────────────────────────────────────────────────────────────
" Native: gt / gT / <count>gt — no plugin binding needed.
nnoremap <silent> <leader>wt :tabnew<CR>
nnoremap <silent> <leader>x  :call TabsVim_CloseOrHide()<CR>
nnoremap <silent> <leader>X  :tabonly<CR>

" Direct tab jumps: <leader>1 … <leader>9 (native <count>gt)
for s:i in range(1, 9)
  execute 'nnoremap <silent> <leader>' . s:i . ' ' . s:i . 'gt'
endfor

" ── Window / split — native commands ─────────────────────────────────────────
nnoremap <silent> <leader>ws :sp<CR>
nnoremap <silent> <leader>wv :vsp<CR>
nnoremap <silent> <leader>wm :only<CR>
nnoremap <silent> <leader>wr :call TabsVim_RenameBuffer()<CR>

" ── Terminal ──────────────────────────────────────────────────────────────────
nnoremap <silent> <leader>ts :call TabsVim_ToggleHorizTerm()<CR>
nnoremap <silent> <leader>tv :call TabsVim_ToggleVertTerm()<CR>
nnoremap <silent> <leader>tt :call TabsVim_NewTabTerm()<CR>

" ── File operations — native commands ────────────────────────────────────────
nnoremap <silent> gF         :tabedit <cfile><CR>
nnoremap <silent> <leader>fy :let @+ = expand("%:p")<CR>
nnoremap <silent> <leader>ft :call TabsVim_FzfOpenInTab()<CR>
```

---

## Keybinding Notes

### `g<number>` for direct tab jumps

`<number>gt` (e.g. `3gt`) is native Vim and requires no plugin function. If you want a shorter shorthand, `g1`–`g9` are unbound in stock Vim and generally free — but `g0` is taken (go to first character of the screen line), so never bind `g0`.

```vim
for s:i in range(1, 9)
  execute 'nnoremap <silent> g' . s:i . ' ' . s:i . 'gt'
endfor
```

This is a pure vimrc concern — no plugin function is needed.

### `<C-]>` for terminal navigation

The primary use case is quickly exiting terminal mode to normal mode so you can scroll, copy, and perform window operations (splits, focus changes, etc.). Vim's native way to do this is `<C-\><C-n>`, which is an awkward two-key chord. `<C-]>` is a natural single-key replacement:

```vim
tnoremap <C-]>  <C-\><C-n>   " exit terminal mode → normal mode (scroll, copy, splits)
```

This mapping is **safe** — `<C-]>` has no meaningful default binding in terminal mode.

**Why `<C-]>` and not `<C-[>`?** `<C-[>` is the ASCII equivalent of `<Esc>` and most terminals send an identical byte sequence for both — Vim cannot distinguish them. Using `<C-[>` as a terminal-exit binding would conflict with any `<Esc>` mapping and produce unreliable behavior across terminal emulators. `<C-]>` sends a distinct byte (`0x1D`) that terminals reliably deliver as-is.

The companion normal-mode mapping is optional and carries a trade-off:

```vim
nnoremap <C-]>  i             " re-enter terminal insert mode from normal mode
```

In normal mode, `<C-]>` is the native "jump to tag under cursor" (ctags / cscope / LSP). Override it only if you do not rely on tag jumping. If you do use tags, leave this one out and use `i` or `a` to re-enter terminal insert mode manually.

---

## Features

| Feature | Description | ADR | Done? |
|---------|-------------|-----|-------|
| **No OOTB keybindings** | Plugin installs zero keymaps; mouse DnD infrastructure only | ADR-004 | ⬜ |
| **Public function API** | All operations promoted to `TabsVim_*` public functions | ADR-004 | ⬜ |
| **Example vimrc block** | Ready-made mapping block for users to copy into vimrc | — | ⬜ |
