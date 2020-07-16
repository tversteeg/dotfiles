" Load the plugins
call plug#begin()

" LSP
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
" Plug 'neovim/nvim-lsp'
" " Check for tags exposed by the language server
" Plug 'weilbith/nvim-lsp-smag'
" LSP status, TODO configure
" Plug 'wbthomason/lsp-status.nvim'

" Git
Plug 'tpope/vim-fugitive'

" Fancy bottom bar with fancy icons
"Plug 'ryanoasis/vim-devicons'
"Plug 'taigacute/spaceline.vim'

" Molokai color theme
Plug 'tomasr/molokai'
" Purple color theme
Plug 'yassinebridi/vim-purpura'

" Surround stuff with cs..
Plug 'tpope/vim-surround'

" Dot commands repeat plugin commands
Plug 'tpope/vim-repeat'

" Comment stuff out gc..
Plug 'tpope/vim-commentary'

" Easier motions
Plug 'easymotion/vim-easymotion'

" Show and remove extra whitespace
Plug 'ntpeters/vim-better-whitespace'

" Fuzzy find
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Rust functions and formatting
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'

" Tables
Plug 'dhruvasagar/vim-table-mode'

" Auto change directory to root of project file
Plug 'airblade/vim-rooter'

"Plug 'junegunn/vim-peekaboo'

" RON syntax
Plug 'ron-rs/ron.vim'

" Highlight f & t symbols
Plug 'unblevable/quick-scope'

" Color text: #FF0000
Plug 'norcalli/nvim-colorizer.lua'

" Switch between relative and absolute numbers
Plug 'jeffkreeftmeijer/vim-numbertoggle'

" Make vim harder
Plug 'takac/vim-hardtime'

" Rainbow parentheses
Plug 'luochen1990/rainbow'

" Automatically balance LISP parentheses
Plug 'eraserhd/parinfer-rust', {'do': 'cargo build --release'}

call plug#end()

" Always use UTF-8
set encoding=utf-8

" Make vim harder to use
let g:hardtime_default_on = 1
let g:list_of_disabled_keys = ["<PageUp>", "<PageDown>"]
let g:hardtime_allow_different_key = 1

" Map fuzzy finding to Ctrl-P in all modes
map <C-p> :GFiles<CR>
map! <C-p> :GFiles<CR>
map <C-.> :FZF<CR>
map! <C-.> :FZF<CR>

" Trigger a highlight in the appropriate direction when pressing these keys:
let g:qs_highlight_on_keys=['f', 'F', 't', 'T']

" Autoformat Rust on save
let g:rustfmt_autosave=1
let g:rustfmt_command='/home/thomas/.cargo/bin/rustfmt +beta '

" Show complete function definition for Rust autocompletions
let g:racer_experimental_completer=1

let g:fzf_files_options='--preview "bat {}"'

" Enable rainbow parentheses
let g:rainbow_active=1

" Disable default mappings
let g:EasyMotion_do_mapping=0

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
nmap s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap s <Plug>(easymotion-overwin-f2)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase=1

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)

" Set the terminal colors and load the colorizer
set termguicolors
lua require'colorizer'.setup()

" :lua << END
" vim.lsp.set_log_level('info')
" 
" local nvim_lsp = require 'nvim_lsp'
" local configs = require 'nvim_lsp/configs'
" configs.cube = {
" 	default_config = {
" 		cmd = {'/home/thomas/c/cube-docugen/lsp/target/release/cube-lsp'},
" 		filetypes = {'lua'},
" 		root_dir = function(fname)
" 			return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
" 		end,
" 		settings = {},
" 	}
" }
" nvim_lsp.cube.setup({})
" END
" 
" " Load the rust-analyzer language server
" lua require'nvim_lsp'.rust_analyzer.setup({})
" 
" " Language server mappings
" nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
" nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
" nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
" nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
" nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
" nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
" nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
" nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
" setlocal omnifunc=v:lua.vim.lsp.omnifunc

let g:LanguageClient_serverCommands = {
     \ 'lua': ['/home/thomas/c/cube-docugen/lsp/target/release/cube-lsp'],
     \ 'rust': ['rust-analyzer'],
     \ }
nnoremap <F5> :call LanguageClient_contextMenu()<CR>
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

" Use syntax highlighting
syntax on

" Use the plugin colorscheme
"colorscheme molokai
colorscheme purpura

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

function! MarkdownFormatting()
	setlocal tabstop=4
	setlocal shiftwidth=4

	" Lua files use UTF-8 encoding
	setlocal encoding=utf-8
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
autocmd Filetype markdown call MarkdownFormatting()

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType yml setlocal ts=2 sts=2 sw=2 expandtab

" Automatically highlight yanked regions
augroup LuaHighlight
	autocmd!
	autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank()
augroup END

" Display the line numbers sidebar
set number
set relativenumber

" Highlight current line
set cursorline
set cursorcolumn

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

" Don't wait 4 seconds
set updatetime=1000

" Set the title
set title
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}

" Give infinite undo across sessions
set undofile
set undodir=~/.vim/undodir

" Show live preview of substitutions
set inccommand=split

" Lua Snippets
iabbrev dbgl print(("%s: %d"):format(debug.getinfo(1).short_src, debug.getinfo(1).currentline)) -- DEBUGLINE

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

" Use <leader>( to add \(\) in regex patterns quickly
"cmap <leader>( \(\)<left><left>
" Use very magic by default
nnoremap / /\v
cnoremap %s/ %s/\v

" Temporary hack to disable the creation of an empty buffer
if @% == ""
	bd
endif
