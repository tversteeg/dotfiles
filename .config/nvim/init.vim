" Load the plugins
call plug#begin()

" Snippets and auto-completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

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
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Rust functions and formatting
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'

" Tables
Plug 'dhruvasagar/vim-table-mode'

" Auto change directory to root of project file
Plug 'airblade/vim-rooter'

" Auto configuration load
Plug '~/vim-rc'

call plug#end()

" Always use UTF-8
set encoding=utf-8

" Map fuzzy finding to Ctrl-P in all modes
map <C-p> :GFiles<CR>
map! <C-p> :GFiles<CR>
map <C-.> :FZF<CR>
map! <C-.> :FZF<CR>

" Autoformat Rust on save
let g:rustfmt_autosave=1

" Show complete function definition for Rust autocompletions
let g:racer_experimental_completer=1

let g:fzf_files_options='--preview "bat {}"'

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <tab> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

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
set makeprg=msbuild\ /nologo\ /m\ /v:q\ /p:Configuration=Debug\ /property:GenerateFullPaths=true\ $*
set errorformat=\ %#%f(%l):\ %m
map <F4> :!start cmd /c "E:/Cube/cube/premake/bin/Debug/Cube.exe" E:/Cube/cube/examples/gui/widgets/widgets.cproject -- --lua-test-arg<CR><CR>
map <F5> :!start cmd /c "E:/Cube/cube/premake/bin/Debug/Cube.exe" -r<CR><CR>
map <silent> <F7> :make! E:/Cube/cube/premake/Cube.sln<CR>
map <silent> <F8> :make! /t:Rebuild E:/Cube/cube/premake/Cube.sln<CR>

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

" Reload vimrc when saved
au BufWritePost init.vim source ~/.config/nvim/init.vim

" Temporary hack to disable the creation of an empty buffer
if @% == ""
	bd
endif
