syntax on

set shiftwidth=4
set tabstop=4
set foldcolumn=2
set foldmethod=syntax

set directory=/tmp

set nocompatible   
filetype off 

set guifont=Terminus\ 8
colorscheme desert

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'

Bundle 'Valloric/YouCompleteMe'

filetype plugin indent on
