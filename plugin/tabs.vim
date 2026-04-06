if exists('g:tabs_vim_loaded')
  finish
endif
let g:tabs_vim_loaded = 1

" Plugin: tabs.vim
" Description: Efficient tab management with modern editor UX
" Version: 0.1.0
" Principles: Locality, Discoverability, Speed, Integration

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" TERMINAL
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let s:term_bufnr  = -1
let s:vterm_bufnr = -1

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

function! s:ResizeTerminals() abort
  for buf in term_list()
    let w = bufwinnr(buf)
    if w > 0 | call term_setsize(buf, winheight(w), winwidth(w)) | endif
  endfor
endfunction

augroup TabsVimTerminal
  autocmd!
  autocmd TerminalOpen,BufEnter,WinEnter * if &buftype ==# 'terminal' | setlocal nonumber norelativenumber | endif
  autocmd VimResized                     * call s:ResizeTerminals()
  autocmd TerminalOpen                   * call term_sendkeys(bufnr(''), 'cd ' . shellescape(getcwd()) . "\n")
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" WINDOW / BUFFER
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Close window or terminal; prompt to quit if it's the last window in the last tab
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

function! TabsVim_RenameBuffer() abort
  let l:new_name = input('Rename buffer: ', expand('%:t'))
  if empty(l:new_name)
    return
  endif
  execute 'file ' . fnameescape(l:new_name)
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ECOSYSTEM
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" g:tabs_vim_tabclose_types: wire q → :tabclose for specified buffer types.
" Must be set before the plugin loads. Supported tokens: 'floggraph', 'git',
" 'diff', or any FileType name matching ^\h\w*$.
if exists('g:tabs_vim_tabclose_types')
  if type(g:tabs_vim_tabclose_types) != type([])
    echohl WarningMsg
    echo 'tabs.vim: g:tabs_vim_tabclose_types must be a List of strings; skipping'
    echohl None
  else
    let s:tabclose_types = filter(copy(g:tabs_vim_tabclose_types),
          \ 'type(v:val) == type("") && !empty(v:val)')
    if !empty(s:tabclose_types)
      augroup TabsVimTabClose
        autocmd!
        for s:tabclose_type in s:tabclose_types
          if s:tabclose_type ==# 'diff'
            " Use <expr> so the mapping re-checks &diff at keypress time;
            " prevents stale q→tabclose after a buffer leaves diff mode.
            autocmd WinEnter * if &diff | nnoremap <silent> <expr> <buffer> q (&diff ? "\<Cmd>tabclose\<CR>" : 'q') | endif
          elseif s:tabclose_type =~# '^\h\w*\%(,\h\w*\)*$'
            execute 'autocmd FileType ' . s:tabclose_type . ' nnoremap <silent> <buffer> q :tabclose<CR>'
          else
            echohl WarningMsg
            echo 'tabs.vim: ignoring invalid tabclose type: ' . string(s:tabclose_type)
            echohl None
          endif
        endfor
        unlet s:tabclose_type
      augroup END
    endif
    unlet s:tabclose_types
  endif
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" DRAG AND DROP
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Drop a file path onto the terminal → open in new tab.
" Requires bracketed-paste support (iTerm2, xterm, etc.).
" Activates only in terminal Vim (not GVim) on Vim 8.0.0210+.
if has('patch-8.0.0210') && !has('gui_running')
  let &t_BE = "\e[?2004h"   " enable bracketed paste on Vim entry
  let &t_BD = "\e[?2004l"   " disable on Vim exit
  exec "set <F30>=\e[200~"
  exec "set <F31>=\e[201~"

  nnoremap <F30>  <Cmd>call <SID>HandleFileDrop()<CR>
  inoremap <F30>  <nop>
  inoremap <F31>  <nop>
  cnoremap <F30>  <nop>
  cnoremap <F31>  <nop>

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
" TAB BAR
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ── Colors ────────────────────────────────────────────────────────────────────
" Override any key via g:tabs_vim_colors: [guifg, guibg, ctermfg, ctermbg]

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

" ── Rendering ─────────────────────────────────────────────────────────────────

function! TabsVim_ModeName() abort
  let l:map = {
    \ 'n':    'N',  'no':   'N·OP',
    \ 'i':    'I',  'ic':   'INSERT',  'ix': 'INSERT',
    \ 'R':    'R',  'Rc':   'REPLACE',
    \ 'v':    'V',  'V':    'V·LINE',  "\<C-v>": 'V·BLOCK',
    \ 's':    'S',  'S':    'S·LINE',  "\<C-s>": 'S·BLOCK',
    \ 'c':    'C',  't':    'T'
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
  let l:hls   = TabsVim_ModeHl()
  let l:style = TabsVim_ModeStyle()
  let l:sel_hl = l:style ==# 'mode' ? '%#TabLineSel#' : l:hls[1]

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

  if l:style !=# 'tabs'
    let s .= '%T%=' . l:hls[0] . ' ' . TabsVim_ModeName() . ' '
  endif

  return s
endfunction

set showtabline=2
set tabline=%!TabsVim_Line()

" ── Refresh ───────────────────────────────────────────────────────────────────

augroup TabsVimRefresh
  autocmd!
  autocmd InsertEnter,InsertLeave,CursorMoved,CursorMovedI,WinEnter * redrawtabline
augroup END
if exists('##ModeChanged')
  augroup TabsVimRefresh
    autocmd ModeChanged * redrawtabline
  augroup END
endif
