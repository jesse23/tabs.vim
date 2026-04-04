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

### Terminology Mismatch: Modern UX vs Vim

When users say "I want to open this file in a tab", they mean different things in different editors:

| User Action | Modern Editor (VSCode, IDE) | Vim (Without tabs.vim) | Result |
|-------------|---------------------------|------------------------|--------|
| "Open file in a new tab" | Creates a new visible tab entry; file becomes active | `tabedit file.txt` (obscure; most users don't know this) | **Confusion**: Users try `:split` instead, which opens in current window, not workspace |
| "Switch between open files" | Click tab, or use `Ctrl+Tab` | `gt` / `gT` (non-standard, hard to discover) | **Friction**: Navigation requires muscle memory for non-standard keys |
| "See all open files" | Tab bar shows all files at a glance | Cycle through tabs with `gt` repeatedly, or use `:ls` | **Inefficiency**: No visual overview; must remember which tab is which |
| "Close a file" | Click X on tab, or use `Ctrl+W` | `:tabclose` or `<leader>wc` (if configured) | **Obscurity**: No obvious keybinding; users default to `:bdelete` instead |
| "Reorder files" | Drag tabs left/right | `:tabmove N` (manual, verbose) | **Barrier**: Tabs don't feel like "things you manage"; feels static |
| "Jump to file N directly" | Click tab N visually, or `Alt+N` | Must know tab number + `:Ntabnext` or scroll to tab | **Discoverability**: No standard binding; `<leader>[1-9]` not obvious |

### Why This Matters

This hierarchy works *against* modern editor intuitions:

1. **User expectation**: "Open file in a tab" → should be simple, it's not
   - Naive approach: `tabedit file.txt` (correct, but obscure)
   - What users try: `split file.txt` (opens in current window, not in new tab)
   - Result: Confusion about what "tab" means

2. **Context loss**: Tabs hide content, not consolidate it
   - In VSCode/IDE: All tabs visible in one row (quick scan)
   - In Vim: Only one tab visible; other tabs' content is hidden
   - Result: Tabs feel like "hidden workspaces" not "open files"

3. **Unnecessary indirection**: Modern users want to *think about files*, not *workspaces*
   - Vim users who work in Vim+tmux circumvent this: one tmux window per logical project section
   - Vim users who use buffers only skip tabs entirely, use `:b` or fuzzy finder
   - Result: Tabs are relegated to power users or ignored completely

### Current Vim Tab Workflow Pain Points

Out of the box, Vim's tab workflow requires:
- `gt` / `gT` to switch (non-standard navigation commands)
- `:tabnew` or `:[N]tabnext` for most operations (verbose, not discoverable)
- No visual affordance that tabs can be a primary navigation method
- Tab indicator styling conflicts with popular color schemes
- No quick jump-to-tab-N (each tab lacks a visible number)
- Tab page line takes precious vertical space but shows minimal information

**User Pain Points:**
1. **Inefficient file switching** — Discovering which tab contains which file requires cycling through tabs visually
2. **Context fragmentation** — Tab state (window layout, cursor position) is hidden; users lose orientation
3. **No direct tab access** — Jumping to a specific open file requires Tab+Tab+Tab or remembering tab number + `:Ntabnext`
4. **Conflicting mental models** — Vim's "tab as workspace" clashes with modern "tab as file" expectation
5. **Poor discoverability** — Which-Key and other help systems don't naturally expose tab commands

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
