syntax on

set shiftwidth=4
set tabstop=4
set foldcolumn=2
set foldmethod=syntax
set expandtab
set autoindent
set smarttab

set lines=50 columns=80

set directory=/tmp

set nocompatible
filetype off

set t_Co=256
set laststatus=2
set noshowmode

set guifont=Terminus\ 8
"set guifont=Inconsolata\ 14
colorscheme desert

au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl set filetype=glsl
au BufNewFile,BufRead SConstruct set filetype=python
au BufNewFile,BufRead sxhkdrc,*.sxhkdrc set filetype=sxhkdrc

filetype plugin indent on
filetype off

function! Gblame(num)
  let l = a:firstline
  exe '!git blame -L' . (l-a:num) . ',' . (l+a:num) . ' % | sed "s/[^(]*(\([^)]*\).*/\1/"'
endfunction
command! -nargs=? Gblame :call Gblame("<args>")
