if exists('g:tabs_vim_loaded')
  finish
endif
let g:tabs_vim_loaded = 1

" Plugin: tabs.vim
" Description: Manage tabs efficiently
" Version: 0.1.0

" Default settings
let g:tabs_debug = get(g:, 'tabs_debug', 0)

" Load main plugin functions
source <sfile>:h/autoload/tabs.vim

if g:tabs_debug
  echom 'tabs.vim loaded'
endif
