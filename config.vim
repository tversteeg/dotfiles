" Load the plugins
call plug#begin()

" Lua check
Plug 'vim-syntastic/syntastic'

" LSP
Plug 'neovim/nvim-lspconfig'
" LSP extensions, type inlay hints
Plug 'nvim-lua/lsp_extensions.nvim'
" " Check for tags exposed by the language server
" Plug 'weilbith/nvim-lsp-smag'
" Fancy completions using LSP as a source
Plug 'nvim-lua/completion-nvim'

" Git
Plug 'tpope/vim-fugitive'
" Show git blame info on the current line
Plug 'APZelos/blamer.nvim'
" Nice commit message editing
Plug 'rhysd/committia.vim'

" Molokai color theme
Plug 'tomasr/molokai'
" Purple color theme
Plug 'yassinebridi/vim-purpura'

" Minimap
Plug 'wfxr/minimap.vim'

" Automatically add closing brackets when going to the next line
Plug 'rstacruz/vim-closer'

" Surround stuff with cs..
Plug 'tpope/vim-surround'

" Dot commands repeat plugin commands
Plug 'tpope/vim-repeat'

" Comment stuff out gc..
Plug 'tpope/vim-commentary'

" Quickly replace text with s
Plug 'svermeulen/vim-subversive'

" Cycle through pasted yanks
Plug 'svermeulen/vim-yoink'

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

" TOML syntax
Plug 'cespare/vim-toml'

" RON syntax
Plug 'ron-rs/ron.vim'

" Dart syntax
Plug 'dart-lang/dart-vim-plugin'

" Kotlin syntax
Plug 'udalov/kotlin-vim'

" Highlight f & t symbols
Plug 'unblevable/quick-scope'

" Color text: #FF0000
Plug 'norcalli/nvim-colorizer.lua'

" Switch between relative and absolute numbers
Plug 'jeffkreeftmeijer/vim-numbertoggle'

" Show buffers in the tabline
Plug 'ap/vim-buftabline'

" Make vim harder
Plug 'takac/vim-hardtime'

" Rainbow parentheses
Plug 'luochen1990/rainbow'

" Highlight variable names
Plug 'jaxbot/semantic-highlight.vim'

" Automatically balance LISP parentheses
Plug 'eraserhd/parinfer-rust', {'do': 'cargo build --release'}

call plug#end()

" Always use UTF-8
set encoding=utf-8

" Enable the blamer function
let g:blamer_enabled = 1

" Use luacheck
let g:syntastic_lua_checkers = ['luacheck']

" Make vim harder to use
let g:hardtime_default_on = 1
let g:list_of_disabled_keys = ["<PageUp>", "<PageDown>"]
let g:hardtime_allow_different_key = 1

" Map fuzzy finding to Ctrl-P in all modes
map <C-p> :GFiles<CR>
map! <C-p> :GFiles<CR>
map <C-.> :FZF<CR>
map! <C-.> :FZF<CR>

" Map subsition to s
nmap s <plug>(SubversiveSubstituteRange)
xmap s <plug>(SubversiveSubstituteRange)
nmap ss <plug>(SubversiveSubstituteWordRange)

" Allow cycling through pastes
"nmap <c-n> <plug>(YoinkPostPasteSwapBack)
"nmap <c-p> <plug>(YoinkPostPasteSwapForward)
nmap p <plug>(YoinkPaste_p)
nmap P <plug>(YoinkPaste_P)

" Trigger a highlight in the appropriate direction when pressing these keys:
let g:qs_highlight_on_keys=['f', 'F', 't', 'T']

" Autoformat Rust on save
let g:rustfmt_autosave=1
let g:rustfmt_command='/home/thomas/.cargo/bin/rustfmt +beta '

" Show complete function definition for Rust autocompletions
let g:racer_experimental_completer=1

" Use bat for FZF previews
let g:fzf_files_options='--preview "bat {}"'

" Enable rainbow parentheses
let g:rainbow_active=1

" Set the terminal colors needed for the colorizer
set termguicolors

" Dart settings
let g:dart_style_guide=2
let dart_html_in_string=v:true

:lua << END

-- Setup the colors for matching text
require'colorizer'.setup()

-- Load cube
local nvim_lsp = require 'lspconfig'
local configs = require 'lspconfig/configs'

-- Attach the plugins to the LSP
local on_attach_vim = function(client)
	require'completion'.on_attach(client)
end

configs.cube = {
	default_config = {
		cmd = {'/home/thomas/c/cube-docugen/lsp/target/release/cube-lsp'},
		filetypes = {'lua'},
		root_dir = function(fname)
			return nvim_lsp.util.find_git_ancestor(fname) or vim.loop.os_homedir()
		end,
		settings = {},
	}
}
nvim_lsp.cube.setup{on_attach=on_attach_vim}

-- Load rust-analyzer
nvim_lsp.rust_analyzer.setup{on_attach=on_attach_vim}
END

" Language server mappings
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> ga    <cmd>lua vim.lsp.buf.code_action()<CR>

" Enable type inlay hints
autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
\ lua require'lsp_extensions'.inlay_hints{ prefix = '', highlight = "NonText" }

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

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing extra messages when using completion
set shortmess+=c

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

" Goto previous/next diagnostic warning/error
nnoremap <silent> g[ <cmd>PrevDiagnosticCycle<cr>
nnoremap <silent> g] <cmd>NextDiagnosticCycle<cr>

" Move across wrapped lines like regular lines
" Go to the first non-blank character of a line
noremap 0 ^
" Just in case you need to go to the very beginning of a line
noremap ^ 0

" Temporary hack to disable the creation of an empty buffer
if @% == ""
	bd
endif
