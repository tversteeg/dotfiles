syntax on

set shiftwidth=4
set tabstop=4

set nocompatible   
filetype off 

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'

Bundle 'Valloric/YouCompleteMe'

filetype plugin indent on
