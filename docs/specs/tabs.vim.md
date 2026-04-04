# tabs.vim

**Version:** 0.1.0  
**Last Updated:** 2026-04-04  
**Status:** Active Development

---

## Overview

`tabs.vim` is a Vim plugin that provides modern, efficient tab management for working with multiple files in Vim. It implements navigational shortcuts, tab creation patterns, and a clean visual hierarchy that transforms Vim's native tab interface from a rarely-used feature into a central workflow primitive.

### Why Tabs?

Modern IDEs organize code into tabs for a reason: **context switching is faster when files stay visible**. Vim users have historically avoided tabs in favor of buffers + splits, but this creates cognitive overhead — you need multiple commands to reason about open files. This plugin reclaims tabs as a first-class citizen.

**Core Principles:**
- **Locality**: Tab actions stay local to their context (navigate, close, create)
- **Discoverability**: Tab-related keybindings are grouped and predictable
- **Speed**: Single-keystroke navigation and creation
- **Integration**: Works naturally with Vim's ecosystem (fzf, git integrations, file trees)

---

## Problem Statement

### Vim's Confusing Hierarchy: Buffer, Window, Tab

Vim's three-tier abstraction is powerful but creates cognitive friction:

| Concept | Definition | Lifespan | Visibility |
|---------|-----------|----------|-----------|
| **Buffer** | In-memory representation of file content | Until explicitly deleted | Hidden (not shown in UI) |
| **Window** | Viewport into a buffer; shows one buffer at a time | Until closed; buffer persists | Shown on screen (split panes) |
| **Tab** | Collection of one or more windows; workspace context | Until closed | One tab visible at a time |

**The Ambiguity Problem:**
- Buffers are *invisible* but *persistent* — users don't see them in the UI, yet they're the fundamental unit
- Windows are *visible* but *tied to tabs* — opening a split in tab A doesn't affect tab B's layout
- Tabs *group windows* but are *optional* — many users never touch them, unaware tabs exist
- **Terminology mismatch**: Modern editors call visible "tabs" what Vim calls "buffers"; Vim's "tabs" are workspaces

### Conceptual Difference: Open File Semantics

The phrase "open a file" has fundamentally different meanings in modern editors vs Vim:

| Concept | Modern Editor (VSCode, IDE) | Vim |
|---------|---------------------------|-----|
| **"Open file"** | Creates a new **visible tab** (one tab per file) | Opens a **buffer in current window** (hidden tabs exist; files stay off-screen) |
| **What "tab" means** | A visible file entry; one tab = one open file | A workspace container; one tab groups multiple windows (buffers in splits) |
| **File visibility** | All open files visible in tab bar; quick scan of what's open | Open files (buffers) are invisible; must use `:ls` or fuzzy finder to see them |
| **Default workflow** | File → Tab bar → Click to switch | File → Buffer list → `:b filename` or fuzzy find to switch |
| **Mental model** | "I work with tabs" (tabs are first-class) | "I work with buffers" (tabs are optional; buffers are first-class) |

**The Gap:**
- Modern users trained in VSCode/IDE expect: **"Open file" = create visible tab**
- Vim users (and the plugin) must think: **"Open file" = create buffer (invisible) + optionally make it visible in a tab**

This semantic difference is why new Vim users are confused. They try to "open a file in a tab" but Vim's default behavior is to open a buffer (which may or may not be in a tab, which may or may not be visible).

### Split Window Misconception

The confusion deepens when users try split windows. Modern editors and Vim have opposite mental models:

| Action | Modern Editor | Vim | Misconception |
|--------|---|---|---|
| **"Split window to view file side-by-side"** | Split creates a **second tab area** in the same editor; file opens in new area | `:split` or `:vsplit` **adds a new window in current tab**; both windows show the same or different buffers | Users think split opens a new independent view; it doesn't—both panes stay in the same tab |
| **Scope of split** | Split is **global** (visible in all tabs) | Split is **tab-scoped** (each tab has independent window layout) | New Vim users expect splits to be "sticky"—if they split in tab A, they expect tab B to remember the split too |
| **Close file in split** | Close a split pane, file remains in other panes or tab bar | `:q` closes the window; buffer persists (can `:b` back to it) | Users try to close a split and expect the file to disappear entirely; it doesn't |

*Example of the Confusion:**
- User opens `file1.txt`, wants to see `file2.txt` alongside it
- Modern editor thinking: "Open in split" → file2 appears in new pane
- Vim reality: `:vsplit` + `:e file2.txt` → two windows in same tab showing both files
- User then opens a new tab (thinking they're working on a new context)
- **Surprise**: The split layout in the first tab doesn't carry over—new tab has single window
- **Result**: Users feel like Vim splits are "temporary" or "tied to a context" when they're actually window layout within a tab

### Terminal Misconception

Modern editors and Vim have opposite mental models for terminal management:

| Concept | Modern Editor (VSCode) | Vim | Misconception |
|---------|---|---|---|
| **Terminal location** | Integrated panel at **bottom of editor** (or side); separate from file tabs | Terminal opens as a **buffer in a window**—just like any other file | Users think terminal is a **separate widget** (like IDE); it's actually just a buffer competing for space |
| **Semantic role** | Terminal is **infrastructure** (always available for commands) | Terminal is **a buffer** (occupies window space like any file) | Users expect terminal to be **persistent** (always accessible); it's not—it's content |
| **Navigation model** | Terminal is **orthogonal** to file editing (exists independently) | Terminal is **part of the workspace** (mixed with files in tabs/windows) | Users think opening a terminal doesn't affect file layout; in Vim, terminal takes a window in the current tab |
| **Visibility assumption** | Terminal should be **always accessible** (one keystroke away) | Terminal is **just another buffer** (need to navigate to it like any file) | Users expect terminal visible across all tabs; in Vim, switching tabs hides the terminal |
| **Multi-tasking** | Multiple terminals can run **in parallel**, visible simultaneously | Each terminal buffer runs in a window; switching tabs hides it | Users expect multiple terminals to stay **visible and running**; in Vim, only current tab's windows are visible |

This is why `tabs.vim` supporting terminal operations (opening terminal in new tab) bridges a conceptual gap—it lets users treat terminal sessions as "tabs" (persistent contexts) rather than "buffers" (hidden unless explicitly switched to).

---

## Design Goals

| Goal | Why | Approach |
|------|-----|----------|
| **Fast Navigation** | Reduce cognitive load when switching files | `<Tab>` / `<S-Tab>` for next/prev; `<leader>[1-9]` for direct jump |
| **Quick Creation** | Open files faster with consistent entry points | `<leader>ft` (fzf) → `tabedit`, `<leader>wt` for new empty tab |
| **Visual Clarity** | Make tabs the center of workflow | Color scheme integration, tab status in statusline |
| **Ecosystem Integration** | Work with existing plugins (fzf, git, file tree) | Respect plugin output, use standard Vim events |
| **Cross-Platform** | Work on macOS, Linux, and Windows with Vim/Neovim | Pure VimScript, no dependencies on external tools |

---

## Architecture

### File Structure

```
tabs.vim/
├── plugin/tabs.vim          # Complete plugin implementation (~300 lines)
├── autoload/                # (reserved for future modularization)
└── README.md                # User documentation
```

**Single-file design**: All tab navigation, creation, terminal handling, and theming logic lives in `plugin/tabs.vim`. This keeps the plugin lightweight and easy to understand while remaining maintainable.

### Design Patterns

**1. Stateless Commands**  
All tab operations are pure Vim commands; no plugin state is maintained. Tab state is delegated to Vim's native tab list. Terminal buffer state is tracked minimally via module-level variables (`s:term_bufnr`, `s:vterm_bufnr`).

**2. Plugin Composition**  
Tabs plugin plays well with others (fzf, Fern, vim-fugitive). It doesn't reimplement file picking or git operations — it just routes output to tabs via `:tabedit`.

**3. Configuration Flexibility**  
All keybindings are configurable. Users can disable features (e.g., if they don't use tabs) without source code changes.

**4. Integrated Theming**  
Dracula color scheme is the built-in default; the tab bar can show a mode pill (Normal/Insert/Visual/Replace/Command/Terminal) and can style the selected tab by mode, depending on `g:tabs_vim_mode_style`. Users may override any or all mode colors via `g:tabs_vim_colors`.

**5. Vimrc Integration Boundary**  
The plugin owns all behavior it directly triggers. Integration with third-party plugins (vim-flog, vim-fugitive, diff buffers) — for example, binding `q` to `:tabclose` in their buffer types — is intentionally left to the user's vimrc. These bindings are tab-aware but depend on optional external plugins; pulling them into tabs.vim would introduce undeclared dependencies and couple the plugin to unrelated workflows.

### Color Configuration Contract

All tab bar colors are configurable via the `g:tabs_vim_colors` global dict. Each key is a lowercase name; each value is a four-element list `[guifg, guibg, ctermfg, ctermbg]`. Unspecified keys fall back to the built-in Dracula defaults. The dict is read once at plugin load time (after `colorscheme` is applied).

The plugin owns the full tab bar and applies all highlight groups itself — no separate `hi TabLine*` declarations are needed in the user's vimrc.

In `all` and `tabs` mode, the selected tab is styled by the active mode color via mode-specific selected-tab groups (`TabsVim_SelNormal`, `TabsVim_SelInsert`, etc.). In `mode`, selected-tab styling comes from `tabline_sel` instead. Changing `normal`, `insert`, `visual`, `replace`, `command`, or `terminal` therefore changes selected-tab appearance in `all` and `tabs` mode.

`tabline`, `tabline_sel`, and `tabline_fill` map to Vim's standard `TabLine`, `TabLineSel`, and `TabLineFill` groups. `tabline_sel` does not control selected-tab styling in `all` or `tabs` mode; in `mode` mode, `tabline_sel` is the selected-tab style source.

**Mode color keys:** `normal`, `insert`, `visual`, `replace`, `command`, `terminal`  
**Tab bar chrome keys:** `tabline`, `tabline_sel`, `tabline_fill`

### Mode Style Contract

Mode style is controlled by `g:tabs_vim_mode_style`.

```vim
" default
let g:tabs_vim_mode_style = 'all'
```

Allowed values:

| Value | Behavior |
|-------|----------|
| `all` | Current behavior: selected-tab color is mode-driven and top-right mode pill is shown |
| `tabs` | Mode-driven selected-tab color remains, but top-right mode pill is hidden |
| `mode` | Top-right mode pill is shown; selected-tab color is fixed to `tabline_sel` |

Unknown values should fall back to `all` for backward compatibility.

**Default (Dracula palette):**

```vim
let g:tabs_vim_colors = {
  \ 'normal':       ['#282a36', '#bd93f9', 235, 141],
  \ 'insert':       ['#282a36', '#50fa7b', 235, 84 ],
  \ 'visual':       ['#282a36', '#ffb86c', 235, 215],
  \ 'replace':      ['#282a36', '#ff5555', 235, 203],
  \ 'command':      ['#282a36', '#bd93f9', 235, 141],
  \ 'terminal':     ['#282a36', '#8be9fd', 235, 117],
  \ 'tabline':      ['#6272a4', 'NONE',    61,  'NONE'],
  \ 'tabline_sel':  ['#bd93f9', 'NONE',    141, 'NONE'],
  \ 'tabline_fill': ['#6272a4', 'NONE',    61,  'NONE'],
\ }
```

**Partial override example (gruvbox-style):**

```vim
" Only change normal and insert; other modes keep Dracula defaults
let g:tabs_vim_colors = {
  \ 'normal': ['#282828', '#d79921', 235, 172],
  \ 'insert': ['#282828', '#b8bb26', 235, 142],
\ }
```

**Design rationale:** This format is borrowed from lightline.vim's palette convention — compact, no named theme indirection, trivially composable. See ADR-002 for alternatives considered.

---

## Implementation Roadmap

### Phase 1: Navigation (MVP)
- `<Tab>` / `<S-Tab>` for next/prev
- `<leader>[1-9]` for direct jumps
- Basic theme support

### Phase 2: Creation & Closing
- `<leader>wt` for new tab
- `<leader>x` / `<leader>X` for close/closeothers
- Integration with fzf for `<leader>ft`

### Phase 3: Integrations
- Fern file tree: open in tabs
- Git diffs/logs: open in tabs
- Terminal support

### Phase 4: Polish
- Which-Key support
- Statusline indicator
- Extended configuration options

---

## Acceptance Criteria

- [ ] All keybindings work as documented
- [ ] Plugin loads without errors in Vim 8.2+ and Neovim 0.7+
- [ ] No conflicts with common plugin ecosystems (fzf, Fern, vim-fugitive)
- [ ] Theming integrates with Dracula (and base16 palette)
- [ ] README and AGENTS.md guide users through setup and customization

---

## Features

| Feature | Description | ADR | Done? |
|---------|-------------|-----|-------|
| **Tab Navigation** | Switch to next/prev tab with `<Tab>` / `<S-Tab>` | — | ✅ |
| **Direct Tab Jump** | Jump to tab 1-9 with `<leader>[1-9]` | — | ✅ |
| **Tab Creation** | Create new tab with `<leader>wt`, via file picker with `<leader>ft` | — | ✅ |
| **Tab Closing** | Close current tab or all but current with `<leader>x` / `<leader>X` | — | ✅ |
| **Tab Appearance** | Dracula default theme; user-configurable colors via `g:tabs_vim_colors` | ADR-002 | ✅ |
| **Mode Style Variants** | `g:tabs_vim_mode_style` supports `all` / `tabs` / `mode` display strategies | ADR-003 | ⬜ |
| **Terminal in Tabs** | Toggle split terminals and spawn tab terminals (`<leader>h/ts/tv/tt`) | — | ✅ |
| **File Tree Integration** | Open files in tabs from Fern file browser (`t` key) | — | ⬜ |
| **Git Integration** | Open git-related output (diffs, logs) in tabs | — | ⬜ |
| **Which-Key Support** | Tab commands exposed in `<Space>` menu hierarchy | — | ⬜ |

---

## Dependencies

- **Vim 8.2+** or **Neovim 0.7+**
- No external tools required
- Optional: fzf (for file picker), Fern (for file tree integration)

---

## Related Specs

None yet.

---

## Revision History

| Date | Change |
|------|--------|
| 2026-04-03 | Initial SPEC: navigation, creation, theming |
| 2026-04-04 | Extend color config: plugin now owns TabLine/TabLineSel/TabLineFill via `tabline`, `tabline_sel`, `tabline_fill` keys |
| 2026-04-04 | Add Vimrc Integration Boundary pattern; mark completed features; align Features table to template |
| 2026-04-04 | Rename to `g:tabs_vim_mode_style` enum (`all` / `tabs` / `mode`) with `all` as default |
