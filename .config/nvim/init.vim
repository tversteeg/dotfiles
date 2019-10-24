" Load the plugins
call plug#begin()

" Language server
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'powershell -executionpolicy bypass -File install.ps1',
    \ }, { 'for': 'rust' }
" Specific language server for vim
Plug 'prabirshrestha/async.vim', { 'for': 'lua' }
Plug 'prabirshrestha/vim-lsp'
" Luacheck
Plug 'vim-syntastic/syntastic', { 'for': 'lua' }

" Git
Plug 'tpope/vim-fugitive'

" Fancy bottom bar with fancy icons
Plug 'ryanoasis/vim-devicons'
Plug 'taigacute/spaceline.vim'

" Molokai color theme
Plug 'tomasr/molokai'

" Show and remove extra whitespace
Plug 'ntpeters/vim-better-whitespace'

" Fuzzy find
Plug 'junegunn/fzf', { 'dir': 'C:/Users/thomas.versteeg/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Rust functions and formatting
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer', { 'for': 'rust' }

" Languages
Plug 'sheerun/vim-polyglot'

" Tables
Plug 'dhruvasagar/vim-table-mode'

" Auto change directory to root of project file
Plug 'airblade/vim-rooter'

" Add 'aa' (an argument), 'ia' (inner argument) text objects (daa) and many others
Plug 'wellle/targets.vim'

" Highlight the number sidebar on specific numbers
Plug 'IMOKURI/line-number-interval.nvim'

" Snippets
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
let g:deoplete#enable_at_startup=1
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'

" Language Tool
Plug 'rhysd/vim-grammarous'

call plug#end()

" Always use UTF-8
set encoding=utf-8

" Map fuzzy finding to Ctrl-P in all modes
map <C-p> :GFiles<CR>
map! <C-p> :GFiles<CR>
map <C-.> :FZF<CR>
map! <C-.> :FZF<CR>

" Use the line number plugin
let g:line_number_interval#enable_at_startup=1
let g:line_number_interval=5

" Autoformat Rust on save
let g:rustfmt_autosave=1

" Show complete function definition for Rust autocompletions
let g:racer_experimental_completer=1

" Show a preview in FZF
let g:fzf_files_options='--preview "bat {}"'

" Language server links
set hidden
let g:LanguageClient_serverCommands = {
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
    \ }
if executable('lua-lsp')
    au User lsp_setup call lsp#register_server({
                \ 'name': 'lua-lsp',
                \ 'cmd': {server_info->[&shell, &shellcmdflag, 'lua-lsp']},
                \ 'whitelist': ['lua'],
                \ })
endif
" Lua syntastic
let g:syntastic_check_on_open=1
let g:syntastic_lua_checkers = ["luac", "luacheck"]
let g:syntastic_lua_luacheck_args = "--no-unused-args"

let g:LanguageClient_autoStart=1
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

" Neosnippet settings
let g:neosnippet#snippets_directory='E:\Snippets'
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)

if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

" Snippets key bindings
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" Split edit vertically
let g:UltiSnipsEditSplit="vertical"

" List the snippets
let g:UltiSnipsListSnippets="<c-l>"

" Set the snippet directories
let g:UltiSnipsSnippetsDir = 'E:\Snippets'
let g:UltiSnipsSnippetDirectories = 'E:\Snippets'

" Use syntax highlighting
syntax on

" Use the molokai plugin colorscheme
colorscheme molokai

highlight HighlightedLineNr guifg=#808080 gui=bold
highlight DimLineNr guifg=#808080

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

" Don't wait 4 seconds
set updatetime=1000

" Set the title
set title
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}

" Give infinite undo across sessions
set undofile
set undodir=~/.vim/undodir

" Map commands for building projects
set makeprg=msbuild\ /nologo\ /m\ /v:q\ /p:Configuration=Release\ /property:GenerateFullPaths=true\ $*
set errorformat=\ %#%f(%l):\ %m
map <F5> :!start cmd /c "E:/Cube/cube/build/bin/Release/Cube.exe" E:/Cube/cube/examples/gui/widgets.lua<CR><CR>
map <silent> <F7> :make! E:/Cube/cube/build/Cube.sln<CR>
map <silent> <F8> :make! /t:Rebuild E:/Cube/cube/build/Cube.sln<CR>

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

" Use j\ to add \(\) in regex patterns quickly
cmap j\ \(\)<left><left>

" Temporary hack to disable the creation of an empty buffer
if @% == ""
	bd
endif
