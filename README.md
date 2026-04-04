# tabs.vim

A lightweight Vim plugin that replaces the tabline with a clean mode-aware bar: tabs on the left, current mode pill on the right. Also provides terminal toggles, tab/window management, and file-drop support.

## Installation

```vim
Plug 'jesse23/tabs.vim'
```

## Features

**Tabline** — always-visible bar showing open tabs (with modified indicator `*`) and a color-coded mode pill (Normal / Insert / Visual / Replace / Command / Terminal).

**Tab navigation**
- `<Tab>` / `<S-Tab>` — next / previous tab
- `<leader>1`–`<leader>9` — jump to tab by number
- `<leader>wt` — new tab
- `<leader>x` / `<leader>X` — close window / close all other tabs

**Split terminals**
- `<leader>h` / `<leader>ts` — toggle horizontal split terminal (15 lines)
- `<leader>tv` — toggle vertical split terminal (80 cols)
- `<leader>tt` — open terminal in a new tab
- `<C-]>` — enter terminal mode; `<Esc>` or `<C-]>` — exit terminal mode

**Window & buffer ops**
- `<leader>ws` / `<leader>wv` — horizontal / vertical split
- `<leader>wm` — maximize (close other windows)
- `<leader>wr` — rename current buffer
- `<leader>fy` — copy file path to clipboard
- `gF` — open file under cursor in new tab

**File drop** — drag a file from Finder onto the terminal; it opens in a new tab (requires bracketed-paste support, e.g. iTerm2).

**FZF integration** — `<leader>ft` opens a file in a new tab via fzf (requires `junegunn/fzf.vim`).

## License

MIT
