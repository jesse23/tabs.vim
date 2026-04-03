" autoload/tabs.vim
" Core functionality for tabs.vim plugin

function! tabs#echo(msg) abort
  if get(g:, 'tabs_debug', 0)
    echom '[tabs.vim] ' . a:msg
  endif
endfunction

function! tabs#version() abort
  return '0.1.0'
endfunction
