" Load the plugins
call plug#begin()

" Molokai color theme
Plug 'tomasr/molokai'

" Language client, mainly for Rust
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }

" Code completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" Run make automatically
Plug 'neomake/neomake', { 'for': ['rust'] }

" Fuzzy find if available
if executable('fzf')
	Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
else
	Plug 'ctrlpvim/ctrlp.vim'
endif

" Rust functions and formatting
"if executable('rustc')
	Plug 'rust-lang/rust.vim'
	Plug 'racer-rust/vim-racer'
"endif

" Git info in the gutter
Plug 'airblade/vim-gitgutter'

call plug#end()

" Needed for vim-racer and LanguageClient
set hidden

" Map fuzzy finding to Ctrl-P in all modes
if executable('fzf')
	map <C-p> :FZF<CR>
	map! <C-p> :FZF<CR>
endif

" Enable deoplete auto completion
let g:deoplete#enable_at_startup=1

" Set the Rust autocompletion paths
let g:racer_cmd='racer'
" Add experimental autocompletion with functions
let g:racer_experimental_completer=1

" Autoformat Rust on save
let g:rustfmt_autosave=1
let g:autofmt_autosave=1

" Set the language server commands for each programming language
let g:LanguageClient_serverCommands={
    \ 'python': ['pyls'],
    \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
    \ 'javascript': ['javascript-typescript-stdio'],
    \ 'go': ['go-langserver'] }

" Always start the language server
let g:LanguageClient_autoStart=1

" Set F2 to rename the current symbol using LanguageClient
nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
" Set K to show information about current location
nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
" Set gd to go to the definition of the current symbol
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>

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

" Don't save swap files
set noswapfile

" Reload vimrc when saved
au BufWritePost init.vim source ~/.config/nvim/init.vim

" Disable arrow keys
nnoremap <right> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <up> <nop>

vnoremap <right> <nop>
vnoremap <down> <nop>
vnoremap <left> <nop>
vnoremap <up> <nop>