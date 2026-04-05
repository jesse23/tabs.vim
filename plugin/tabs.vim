if exists('g:tabs_vim_loaded')
  finish
endif
let g:tabs_vim_loaded = 1

" Plugin: tabs.vim
" Description: Efficient tab management with modern editor UX
" Version: 0.1.0
" Principles: Locality, Discoverability, Speed, Integration

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Terminal State (for split terminal toggle)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:term_bufnr  = -1
let s:vterm_bufnr = -1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TERMINAL: Split terminals & new tab terminal
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:ToggleTerm(bufvar, open_cmd, resize_cmd) abort
  let bufnr = eval(a:bufvar)
  for w in range(1, winnr('$'))
    if winbufnr(w) == bufnr
      execute w . 'wincmd w' | hide | return
    endif
  endfor
  if bufnr > 0 && bufexists(bufnr)
    execute a:open_cmd . ' sbuffer ' . bufnr
    execute a:resize_cmd | return
  endif
  execute a:open_cmd . ' term'
  execute 'let ' . a:bufvar . ' = bufnr("")'
  setlocal nobuflisted
  execute a:resize_cmd
endfunction

function! TabsVim_ToggleHorizTerm() abort
  call s:ToggleTerm('s:term_bufnr', 'below', 'resize 15')
endfunction

function! TabsVim_ToggleVertTerm() abort
  call s:ToggleTerm('s:vterm_bufnr', 'vertical', 'vertical resize 80')
endfunction

function! TabsVim_NewTabTerm() abort
  tab term
  setlocal nobuflisted
endfunction

" Terminal settings
augroup TermSettings
  autocmd!
  " No line numbers in terminal windows
  autocmd TerminalOpen,BufEnter,WinEnter * if &buftype ==# 'terminal' | setlocal nonumber norelativenumber | endif
  " Resize terminal buffers when vim window size changes
  autocmd VimResized * call s:ResizeTerminals()
  " Keep newly opened terminals in the current working directory
  autocmd TerminalOpen * call term_sendkeys(bufnr(''), 'cd ' . shellescape(getcwd()) . "\n")
augroup END

function! s:ResizeTerminals() abort
  for buf in term_list()
    let w = bufwinnr(buf)
    if w > 0 | call term_setsize(buf, winheight(w), winwidth(w)) | endif
  endfor
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" WINDOWS & BUFFERS
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Close window or terminal, with prompt to quit if it's the last window in the last tab
function! TabsVim_CloseOrHide() abort
  if tabpagenr('$') == 1 && winnr('$') == 1
    if confirm('Quit Vim?', "&Yes\n&No", 2) == 1
      qall!
    endif
    return
  endif

  if &buftype ==# 'terminal'
    if bufnr('%') == s:vterm_bufnr
      call s:ToggleTerm('s:vterm_bufnr', 'vertical', 'vertical resize 80')
    elseif bufnr('%') == s:term_bufnr
      call s:ToggleTerm('s:term_bufnr', 'below', 'resize 15')
    else
      close
    endif
  else
    close
  endif
endfunction

" Rename current buffer
function! TabsVim_RenameBuffer() abort
  let l:new_name = input('Rename buffer: ', expand('%:t'))
  if empty(l:new_name)
    return
  endif
  execute 'file ' . fnameescape(l:new_name)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" FZF Integration: Open files in tabs
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! TabsVim_FzfOpenInTab() abort
  if !exists('*fzf#vim#files') || !exists('*fzf#vim#with_preview')
    echohl WarningMsg
    echo 'tabs.vim: TabsVim_FzfOpenInTab requires fzf.vim (fzf#vim#files not available)'
    echohl None
    return
  endif
  call fzf#vim#files('', fzf#vim#with_preview({'sink': 'tabedit'}), 0)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DRAG-AND-DROP: Drop a file path onto the terminal → open in new tab
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Requires bracketed-paste support in the terminal (iTerm2, xterm, etc.)
" Drag a file from Finder/Explorer → terminal sends ESC[200~path ESC[201~
if has('patch-8.0.0210') && !has('gui_running')
  let &t_BE = "\e[?2004h"   " enable bracketed paste on Vim entry
  let &t_BD = "\e[?2004l"   " disable on Vim exit
  exec "set <F30>=\e[200~"
  exec "set <F31>=\e[201~"

  " Normal mode: intercept bracket-paste start, collect path, open in new tab
  nnoremap <F30> <Cmd>call <SID>HandleFileDrop()<CR>

  " Insert mode: swallow paste markers
  inoremap <F30> <nop>
  inoremap <F31> <nop>

  " Command mode: silently swallow the markers so pasted text is clean
  cnoremap <F30> <nop>
  cnoremap <F31> <nop>

  function! s:HandleFileDrop() abort
    let text = ''
    while 1
      let c = getchar()
      if type(c) == type('') | break | endif
      let text ..= nr2char(c)
    endwhile
    let path = trim(text)
    if filereadable(path) || isdirectory(path)
      execute 'tabedit ' .. fnameescape(path)
    else
      echohl WarningMsg | echo 'Not a file: ' .. path | echohl None
    endif
  endfunction
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tab bar — replaces status line: mode (left) | tabs (center) | position (right)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ══════════════════════════════════════════════════════════════════════════════
" MODE COLORS — override any mode via g:tabs_vim_colors (see docs/specs/tabs.vim.md)
" Each entry: [guifg, guibg, ctermfg, ctermbg]
let s:tabs_vim_defaults = {
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

function! s:ApplyColors() abort
  let l:user = exists('g:tabs_vim_colors') ? g:tabs_vim_colors : {}
  for [l:key, l:Cap] in [['normal', 'Normal'], ['insert', 'Insert'], ['visual', 'Visual'],
                        \ ['replace', 'Replace'], ['command', 'Command'], ['terminal', 'Terminal']]
    let l:ov  = get(l:user, l:key, [])
    let l:col = (type(l:ov) == type([]) && len(l:ov) == 4) ? l:ov : s:tabs_vim_defaults[l:key]
    execute printf('hi TabsVim_%s guifg=%s guibg=%s ctermfg=%s ctermbg=%s gui=bold cterm=bold',
          \ l:Cap, l:col[0], l:col[1], l:col[2], l:col[3])
    execute printf('hi TabsVim_Sel%s guifg=%s guibg=NONE ctermfg=%s ctermbg=NONE gui=bold cterm=bold',
          \ l:Cap, l:col[1], l:col[3])
  endfor
  let l:ov = get(l:user, 'normal', [])
  let l:n  = (type(l:ov) == type([]) && len(l:ov) == 4) ? l:ov : s:tabs_vim_defaults['normal']
  execute printf('hi TabsVim_Accent guifg=%s guibg=%s ctermfg=%s ctermbg=%s gui=bold cterm=bold',
        \ l:n[0], l:n[1], l:n[2], l:n[3])
  for [l:key, l:Group, l:bold] in [
        \ ['tabline',      'TabLine',     'NONE'],
        \ ['tabline_sel',  'TabLineSel',  'bold'],
        \ ['tabline_fill', 'TabLineFill', 'NONE']]
    let l:ov  = get(l:user, l:key, [])
    let l:col = (type(l:ov) == type([]) && len(l:ov) == 4) ? l:ov : s:tabs_vim_defaults[l:key]
    execute printf('hi %s guifg=%s guibg=%s ctermfg=%s ctermbg=%s gui=%s cterm=%s',
          \ l:Group, l:col[0], l:col[1], l:col[2], l:col[3], l:bold, l:bold)
  endfor
endfunction

call s:ApplyColors()
" ══════════════════════════════════════════════════════════════════════════════

set showtabline=2

function! TabsVim_ModeName() abort
  let l:map = {
    \ 'n':    'N',  'no':   'N·OP',
    \ 'i':    'I',  'ic':   'INSERT',  'ix': 'INSERT',
    \ 'R':    'R', 'Rc':   'REPLACE',
    \ 'v':    'V',  'V':    'V·LINE',  "\<C-v>": 'V·BLOCK',
    \ 's':    'S',  'S':    'S·LINE',  "\<C-s>": 'S·BLOCK',
    \ 'c':    'C', 't':    'T'
  \ }
  return get(l:map, mode(), mode())
endfunction

function! TabsVim_ModeHl() abort
  let l:m = mode()
  if     l:m =~# '^[vV\x16]' | return ['%#TabsVim_Visual#',   '%#TabsVim_SelVisual#']
  elseif l:m =~# '^[iI]'     | return ['%#TabsVim_Insert#',   '%#TabsVim_SelInsert#']
  elseif l:m =~# '^[rR]'     | return ['%#TabsVim_Replace#',  '%#TabsVim_SelReplace#']
  elseif l:m =~# '^c'        | return ['%#TabsVim_Command#',  '%#TabsVim_SelCommand#']
  elseif l:m =~# '^t'        | return ['%#TabsVim_Terminal#', '%#TabsVim_SelTerminal#']
  else                        | return ['%#TabsVim_Normal#',   '%#TabsVim_SelNormal#']
  endif
endfunction

function! TabsVim_ModeStyle() abort
  let l:style = get(g:, 'tabs_vim_mode_style', 'all')
  if index(['all', 'tabs', 'mode'], l:style) < 0
    return 'all'
  endif
  return l:style
endfunction

function! TabsVim_Line() abort
  let l:hls = TabsVim_ModeHl()   " [pill_hl, sel_tab_hl]
  let l:style = TabsVim_ModeStyle()
  let l:sel_hl = l:style ==# 'mode' ? '%#TabLineSel#' : l:hls[1]
  " ── Left: tabs (%NT = native Vim click-to-switch + drag)
  let s = ''
  for t in range(1, tabpagenr('$'))
    let buflist = tabpagebuflist(t)
    let buf     = buflist[tabpagewinnr(t) - 1]
    let name    = bufname(buf)
    let name    = empty(name) ? '[No Name]' : fnamemodify(name, ':t')
    let mod     = getbufvar(buf, '&modified') ? ' *' : ''
    let s .= t == tabpagenr() ? l:sel_hl : '%#TabLine#'
    let s .= '%' . t . 'T'
    let s .= ' ' . t . ' ' . name . mod . ' '
    if t < tabpagenr('$') | let s .= '%#TabLineFill#│' | endif
  endfor

  " ── Right: mode block ───────────────────────────────────────────────────────
  if l:style !=# 'tabs'
    let s .= '%T%=' . l:hls[0] . ' ' . TabsVim_ModeName() . ' '
  endif

  return s
endfunction

set tabline=%!TabsVim_Line()

" Refresh tabline on mode change and cursor movement
augroup TabsVimRefresh
  autocmd!
  autocmd InsertEnter,InsertLeave,CursorMoved,CursorMovedI,WinEnter * redrawtabline
augroup END
if exists('##ModeChanged')
  augroup TabsVimRefresh
    autocmd ModeChanged * redrawtabline
  augroup END
endif
