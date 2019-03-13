" Load the plugins
call plug#begin()

" Molokai color theme
Plug 'tomasr/molokai'

" Tab completions
Plug 'ervandew/supertab'

" Tab completions syntax based
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

" Automatically call linters for different source code types
Plug 'neomake/neomake'

" Show and remove extra whitespace
Plug 'ntpeters/vim-better-whitespace'

" Fuzzy find
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Automatically use correct tabs/spaces when defined
Plug 'editorconfig/editorconfig-vim'

" Ack
Plug 'mileszs/ack.vim'

" Rust functions and formatting
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'

" C++ highlighting
Plug 'octol/vim-cpp-enhanced-highlight'

" Lua indentation & colors
Plug 'tbastos/vim-lua'

" Git
Plug 'tpope/vim-fugitive'
" Git sidebar
Plug 'airblade/vim-gitgutter'

" JSON
Plug 'elzr/vim-json'

" Markdown
Plug 'plasticboy/vim-markdown'

" TOML
Plug 'cespare/vim-toml'

" Powershell
Plug 'PProvost/vim-ps1'

" Cap'n Proto
Plug 'peter-edge/vim-capnp'

" Perl 5 & 6
Plug 'vim-perl/vim-perl'

" Status bar
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Fancy icons
Plug 'ryanoasis/vim-devicons'

" Tables
Plug 'dhruvasagar/vim-table-mode'

" Calculator
" normal g={motion} evaluate the motion
" normal g== evaluate the line
" visual g= evaluate the highlight
Plug 'arecarn/crunch.vim'

" Rainbow parentheses
Plug 'luochen1990/rainbow'

" Highlight the current keyword
Plug 'RRethy/vim-illuminate'

" Startup screen
Plug 'mhinz/vim-startify'

" crs to snake_case, crc to camelCase, cru to UPPER_CASE
Plug 'tpope/vim-abolish'

" Enhance f, F, t, T, ; & ,
Plug 'unblevable/quick-scope'

" Highlight yank regions
Plug 'machakann/vim-highlightedyank'

call plug#end()

" Map fuzzy finding to Ctrl-P in all modes
map <C-p> :GFiles<CR>
map! <C-p> :GFiles<CR>
map <C-.> :FZF<CR>
map! <C-.> :FZF<CR>

" Use deoplete
let g:deoplete#enable_at_startup = 1

" Activate rainbow parentheses
let g:rainbow_active = 1

" Autoformat Rust on save
let g:rustfmt_autosave=1

" Don't fold the top header
let g:vim_markdown_folding_level=2

" Set the airline theme
let g:airline_theme='tomorrow'
let g:airline_powerline_fonts=1

" Automatically remove extra whitespace
let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1

let g:fzf_files_options = '--preview "bat {}"'

" Run neomake at every save
call neomake#configure#automake('w')

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

	" Use gq to format
	set formatprg=astyle\ -A1tSwYpxgHk1W1xbjxfxC100xt1m1M80z2\ --mode=c
	setlocal colorcolumn=100
	highlight OverLength ctermbg=red ctermfg=white guibg=#592929
endfunction

function! RustFormatting()
	" Set the tabsizes and behavior
	setlocal tabstop=4
	setlocal shiftwidth=4

	" Rust files use UTF-8 encoding
	setlocal encoding=utf-8
endfunction

function! LuaFormatting()
	setlocal tabstop=4
	setlocal shiftwidth=4

	" Lua files use UTF-8 encoding
	setlocal encoding=utf-8

	" Use Cube-style comments
	setlocal comments=:---
endfunction

" Set the Lua type for Cube types
autocmd BufRead,BufNewFile *.cproject setfiletype lua
autocmd BufRead,BufNewFile *.ctheme setfiletype lua
autocmd BufRead,BufNewFile *.cconfig setfiletype lua
autocmd BufRead,BufNewFile *.cmodule setfiletype lua
autocmd BufRead,BufNewFile *.ctest setfiletype lua

autocmd Filetype c call CFormatting()
autocmd Filetype cpp call CppFormatting()
autocmd Filetype rust call RustFormatting()
autocmd Filetype lua call LuaFormatting()

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

" Always show the sign column
set signcolumn=yes

" Set the title
set title
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}

" Give infinite undo across sessions
set undofile
set undodir=~/.vim/undodir

" Map commands for building projects
set makeprg=msbuild\ /nologo\ /m\ /v:q\ /p:Configuration=Debug\ /property:GenerateFullPaths=true\ $*
set errorformat=\ %#%f(%l):\ %m
map <F4> :!start cmd /c "E:/Cube/cube/premake/bin/Debug/Cube.exe" E:/Cube/cube/examples/gui/widgets/widgets.cproject -- --lua-test-arg<CR><CR>
map <F5> :!start cmd /c "E:/Cube/cube/premake/bin/Debug/Cube.exe" -r<CR><CR>
map <silent> <F7> :make! E:/Cube/cube/premake/Cube.sln<CR>
map <silent> <F8> :make! /t:Rebuild E:/Cube/cube/premake/Cube.sln<CR>

" Lua Snippets
iabbrev dbgl print(("%s: %d"):format(debug.getinfo(1).short_src, debug.getinfo(1).currentline)) -- DEBUGLINE

" Set the terminal to git bash
map <F1> :vsplit term://E:/Cube/cube//bash<CR>
map <F2> :vsplit term://bash<CR>
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

" Use jj instead of <esc>
inoremap jj <esc>
inoremap <esc> <nop>

" Move across wrapped lines like regular lines
" Go to the first non-blank character of a line
noremap 0 ^
" Just in case you need to go to the very beginning of a line
noremap ^ 0

" Reload vimrc when saved
au BufWritePost init.vim source ~/.config/nvim/init.vim

" Temporary hack to disable the creation of an empty buffer
if @% == ""
	bd
endif
