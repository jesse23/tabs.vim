# tabs.vim

**Version:** 0.1.0  
**Last Updated:** 2026-04-03  
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

Out of the box, Vim's tab workflow requires:
- `gt` / `gT` to switch (non-standard, hard to remember)
- `:tabnew` or `:[N]tabnext` for most operations (verbose)
- No visual affordance that tabs are a primary navigation method
- Tab indicator styling conflicts with popular color schemes

**User Pain Points:**
1. Inefficient switching between multiple open files
2. Context loss when closing or reordering tabs
3. No quick way to navigate directly to tab N
4. Terminal integration doesn't expose tab state clearly

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

## Features

| Feature | Description | Status | ADR |
|---------|-------------|--------|-----|
| **Tab Navigation** | Switch to next/prev tab with `<Tab>` / `<S-Tab>` | ⬜ | — |
| **Direct Tab Jump** | Jump to tab 1-9 with `<leader>[1-9]` | ⬜ | — |
| **Tab Creation** | Create new tab with `<leader>wt`, via file picker with `<leader>ft` | ⬜ | — |
| **Tab Closing** | Close current tab or all but current with `<leader>x` / `<leader>X` | ⬜ | — |
| **Tab Appearance** | Dracula theme integration, minimal visual overhead | ⬜ | — |
| **File Tree Integration** | Open files in tabs from Fern file browser (`t` key) | ⬜ | — |
| **Git Integration** | Open git-related output (diffs, logs) in tabs | ⬜ | — |
| **Terminal in Tabs** | Spawn terminal windows in new tabs (separate from splits) | ⬜ | — |
| **Which-Key Support** | Tab commands exposed in `<Space>` menu hierarchy | ⬜ | — |

---

## Architecture

### Module Structure

```
tabs.vim/
├── plugin/tabs.vim          # Entry point, settings initialization
├── autoload/tabs.vim        # Core functions (navigation, creation, events)
├── autoload/tabs/nav.vim    # Navigation commands
├── autoload/tabs/create.vim # Tab creation patterns
├── autoload/tabs/ui.vim     # Visual customizations (colors, statusline)
└── README.md                # User documentation
```

### Design Patterns

**1. Stateless Commands**  
All tab operations are pure Vim commands; no plugin state is maintained. Tab state is delegated to Vim's native tab list.

**2. Plugin Composition**  
Tabs plugin plays well with others (fzf, Fern, vim-fugitive). It doesn't reimplement file picking or git operations — it just routes output to tabs.

**3. Configuration Flexibility**  
All keybindings are configurable. Users can disable features (e.g., if they don't use tabs) without source code changes.

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
