" Load the plugins
call plug#begin()

" Molokai color theme
Plug 'tomasr/molokai'

" Code completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'sebastianmarkow/deoplete-rust'

" Fuzzy find
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Rust functions and formatting
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'

" C++ highlighting
Plug 'octol/vim-cpp-enhanced-highlight'

" Replace syntastic
Plug 'neomake/neomake'

" Git
Plug 'tpope/vim-fugitive'

" Markdown
Plug 'plasticboy/vim-markdown'

" TOML
Plug 'cespare/vim-toml'

call plug#end()

" Map fuzzy finding to Ctrl-P in all modes
map <C-p> :GFiles<CR>
map! <C-p> :GFiles<CR>
map <C-.> :FZF<CR>
map! <C-.> :FZF<CR>

" Enable deoplete auto completion
let g:deoplete#enable_at_startup=1

" Autoformat Rust on save
let g:rustfmt_autosave=1

" Don't fold the top header
let g:vim_markdown_folding_level = 2

" Make neomake run every time the file is saved
"call neomake#configure#automake('w')

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
endfunction

function! CppFormatting()
	" Set the tabsizes and behavior
	setlocal tabstop=4
	setlocal shiftwidth=4
	setlocal expandtab
	setlocal autoindent
	setlocal smartindent
	setlocal smarttab
endfunction

function! RustFormatting()
	" Set the tabsizes and behavior
	setlocal tabstop=4
	setlocal shiftwidth=4

	" Rust files use UTF-8 encoding
	setlocal encoding=utf-8
endfunction

" Set the Lua type for Cube types
autocmd BufRead,BufNewFile *.cproject setfiletype lua
autocmd BufRead,BufNewFile *.ctheme setfiletype lua
autocmd BufRead,BufNewFile *.cconfig setfiletype lua
autocmd BufRead,BufNewFile *.cmodule setfiletype lua

autocmd Filetype c call CFormatting()
autocmd Filetype cpp call CppFormatting()
autocmd Filetype rust call RustFormatting()

" Set folding
set foldcolumn=2
set foldmethod=syntax

" Display the line numbers sidebar
set number
set relativenumber

" Highlight current line
set cul

" Set the minimal width of the window
set winwidth=80

" Reload files changed outside vim
set autoread

" Don't use swap files
set noswapfile

" Automatically change the working directory to the current file
set autochdir

" Automatically hide some symbols (used by markdown)
set conceallevel=2

" Set the title
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}

" Map commands for building projects
set makeprg=msbuild\ /nologo\ /v:q\ /property:GenerateFullPaths=true\ $*
set errorformat=\ %#%f(%l):\ %m
map <F7> :make
map <F8> :make /t:Rebuild

" Set the terminal to git bash
map <F1> :vsplit term://bash<CR>
" Exit terminal mode
tnoremap <Esc> <C-\><C-n> 

" Automatically enter terminal mode
autocmd TermOpen * startinsert

" Unmap arrow keys
nnoremap <right> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <up> <nop>

vnoremap <right> <nop>
vnoremap <down> <nop>
vnoremap <left> <nop>
vnoremap <up> <nop>
