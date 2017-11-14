" Load the plugins
call plug#begin()

" Molokai color theme
Plug 'tomasr/molokai'

" Code completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-clang'

" Fuzzy find
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

call plug#end()

" Map fuzzy finding to Ctrl-P in all modes
map <C-p> :FZF<CR>
map! <C-p> :FZF<CR>

" Enable deoplete auto completion
let g:deoplete#enable_at_startup=1

" Use syntax highlighting
syntax on

" Use the molokai plugin colorscheme
colorscheme molokai

" Set the tabsizes and behavior
set tabstop=8
set shiftwidth=8
set noexpandtab
set autoindent
set smartindent

" Make the arguments in C script indent nicely
set cino+=(0

" Set the column for line wrapping
set colorcolumn=80
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.*/

" Set folding
set foldcolumn=2
set foldmethod=syntax

" Set the neovim-qt font
let g:GuiFont="Inconsolata:h11"

" Display the line numbers sidebar
set number
set relativenumber

" Highlight current line
set cul
