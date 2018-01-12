" Load the plugins
call plug#begin()

" Molokai color theme
Plug 'tomasr/molokai'

" Code completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-clang'

" Fuzzy find
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Rust functions and formatting
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'

call plug#end()

" Map fuzzy finding to Ctrl-P in all modes
map <C-p> :FZF<CR>
map! <C-p> :FZF<CR>

" Enable deoplete auto completion
let g:deoplete#enable_at_startup=1

" Set the Rust autocompletion paths
let g:racer_cmd='/home/thomas/.cargo/bin/racer'
" Add experimental autocompletion with functions
let g:racer_experimental_completer = 1

" Autoformat Rust on save
let g:rustfmt_autosave=1

" Use syntax highlighting
syntax on

" Use the molokai plugin colorscheme
colorscheme molokai

function! CFormatting()
	" Set the tabsizes and behavior
	setlocal tabstop=8
	setlocal shiftwidth=8
	setlocal noexpandtab
	setlocal autoindent
	setlocal smartindent

	" Make the arguments in C script indent nicely
	setlocal cino+=(0

	" Set the column for line wrapping
	setlocal colorcolumn=80
	highlight OverLength ctermbg=red ctermfg=white guibg=#592929
	match OverLength /\%81v.*/

	" Set folding
	set foldcolumn=2
endfunction

function! RustFormatting()
	" Set the tabsizes and behavior
	setlocal tabstop=4
	setlocal shiftwidth=4

	" Rust files use UTF-8 encoding
	setlocal encoding=utf-8
endfunction

autocmd Filetype c call CFormatting()
autocmd Filetype rust call RustFormatting()

" Set folding
set foldcolumn=2
set foldmethod=syntax

" Set the neovim-qt font
let g:GuiFont="Inconsolata:h9"

" Display the line numbers sidebar
set number
set relativenumber

" Highlight current line
set cul

" Set to auto read when a file is changed from the outside
set autoread

" Set the title of the window
set title

" Reload vimrc when saved
au BufWritePost init.vim source ~/.config/nvim/init.vim
