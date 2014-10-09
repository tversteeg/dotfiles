syntax on

set shiftwidth=4
set tabstop=4
set foldcolumn=2
set foldmethod=syntax

set lines=50 columns=80

set directory=/tmp

set nocompatible
filetype off

set guifont=Terminus\ 8
colorscheme desert

au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl set filetype=glsl

filetype plugin indent on
