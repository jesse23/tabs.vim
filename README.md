# tabs.vim

A lightweight Vim plugin that replaces the native tabline with a clean, mode-aware bar: numbered tabs on the left, a color-coded mode pill on the right. Also handles split terminals, tab/window management, and file-drop support.

## Requirements

- Vim 8.2+ or Neovim 0.7+
- Optional: [junegunn/fzf.vim](https://github.com/junegunn/fzf.vim) for file-picker integration

## Installation

```vim
Plug 'jesse23/tabs.vim'
```

## Keybindings

**Tab navigation**
- `<Tab>` / `<S-Tab>` — next / previous tab
- `<leader>1`–`<leader>9` — jump to tab by number

**Tab management**
- `<leader>wt` — new empty tab
- `<leader>ft` — open file in new tab via fzf
- `<leader>x` / `<leader>X` — close window / close all other tabs
- `gF` — open file under cursor in new tab

**Splits & windows**
- `<leader>ws` / `<leader>wv` — horizontal / vertical split
- `<leader>wm` — maximize (close other windows)

**Buffer ops**
- `<leader>wr` — rename current buffer
- `<leader>fy` — copy file path to clipboard

**Terminals**
- `<leader>h` / `<leader>ts` — toggle horizontal split terminal (15 lines)
- `<leader>tv` — toggle vertical split terminal (80 cols)
- `<leader>tt` — open terminal in new tab
- `<C-]>` — enter terminal mode; `<Esc>` or `<C-]>` — exit

**File drop** — drag a file from Finder onto the terminal to open it in a new tab (requires bracketed-paste, e.g. iTerm2).

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
