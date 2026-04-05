# tabs.vim

A lightweight Vim plugin that replaces the native tabline with a clean, mode-aware bar: numbered tabs on the left, a color-coded mode pill on the right. Exposes public functions for terminal toggling, window management, and ecosystem integrations — no keybindings installed out of the box.

## Requirements

- Vim 8.2+ or Neovim 0.7+
- Optional: [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim) for file-picker integration
- Optional: [vim-flog](https://github.com/rbong/vim-flog) for git log integration

## Installation

```vim
Plug 'jesse23/tabs.vim'
```

## Setup

The plugin installs **no keybindings** by default — add the ones you want to your `vimrc`. Copy and adapt the block below:

```vim
" ── Tab navigation ────────────────────────────────────────────────────────────
" Native: gt / gT / <count>gt — no plugin binding needed.
nnoremap <silent> <leader>wt :tabnew<CR>
nnoremap <silent> <leader>x  :call TabsVim_CloseOrHide()<CR>
nnoremap <silent> <leader>X  :tabonly<CR>

" Direct tab jumps: <leader>1 … <leader>9
for s:i in range(1, 9)
  execute 'nnoremap <silent> <leader>' . s:i . ' ' . s:i . 'gt'
endfor

" ── Window / split ────────────────────────────────────────────────────────────
nnoremap <silent> <leader>ws :sp<CR>
nnoremap <silent> <leader>wv :vsp<CR>
nnoremap <silent> <leader>wm :only<CR>
nnoremap <silent> <leader>wr :call TabsVim_RenameBuffer()<CR>

" ── Terminal ──────────────────────────────────────────────────────────────────
nnoremap <silent> <leader>ts :call TabsVim_ToggleHorizTerm()<CR>
nnoremap <silent> <leader>tv :call TabsVim_ToggleVertTerm()<CR>
nnoremap <silent> <leader>tt :call TabsVim_NewTabTerm()<CR>
tnoremap          <C-]>      <C-\><C-n>   " exit terminal mode

" ── File operations ───────────────────────────────────────────────────────────
nnoremap <silent> gF         :tabedit <cfile><CR>
nnoremap <silent> <leader>fy :let @+ = expand("%:p")<CR>
nnoremap <silent> <leader>ft :call TabsVim_FzfOpenInTab()<CR>

" ── Git log ───────────────────────────────────────────────────────────────────
nnoremap <silent> <leader>gg :call TabsVim_FlogInTab()<CR>

" ── Ecosystem buffer close (q → :tabclose) ───────────────────────────────────
" Must be set before the plugin loads/is sourced (e.g. before plug#end() when using vim-plug).
let g:tabs_vim_tabclose_types = ['floggraph', 'git', 'diff']
```

**File drop** — drag a file from Finder onto the terminal to open it in a new tab (requires bracketed-paste, e.g. iTerm2). This is the only behavior installed automatically.

## Public API

| Function | Description |
|----------|-------------|
| `TabsVim_ToggleHorizTerm()` | Toggle persistent horizontal split terminal (below, 15 rows) |
| `TabsVim_ToggleVertTerm()` | Toggle persistent vertical split terminal (right, 80 cols) |
| `TabsVim_NewTabTerm()` | Open a new terminal in its own tab |
| `TabsVim_CloseOrHide()` | Close window; if last window prompt to quit; if terminal, hide it |
| `TabsVim_RenameBuffer()` | Prompt to rename the current buffer |
| `TabsVim_FzfOpenInTab()` | Open fzf file picker with `tabedit` as the sink (requires fzf.vim) |
| `TabsVim_FlogInTab()` | Open vim-flog git log in a new tab (requires vim-flog) |

## Configuration

### Mode style

Controls what the tabline shows:

```vim
" all   — mode-driven selected tab + mode pill (default)
" tabs  — mode-driven selected tab, no pill
" mode  — mode pill, fixed selected-tab color
let g:tabs_vim_mode_style = 'all'
```

### Colors

Override any color via `g:tabs_vim_colors`. Each value is `[guifg, guibg, ctermfg, ctermbg]`:

```vim
" Partial override — unspecified keys keep Dracula defaults
let g:tabs_vim_colors = {
  \ 'normal': ['#282828', '#d79921', 235, 172],
  \ 'insert': ['#282828', '#b8bb26', 235, 142],
\ }
```

Mode keys: `normal`, `insert`, `visual`, `replace`, `command`, `terminal`  
Chrome keys: `tabline`, `tabline_sel`, `tabline_fill`

See `:help tabs.vim` for the full reference.

## License

MIT
