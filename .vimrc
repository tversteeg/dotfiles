"========== GENERAL

" Reset to vim-defaults
if &compatible
	set nocompatible
endif

" Set preview to UTF-8
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf8,prc

" Set the tabsizes and behavior
set tabstop=8
set shiftwidth=8
set noexpandtab
set autoindent
set smartindent

" Set the directory for the ~ files
if has("win32")
	set directory=C:\Users\thomas.versteeg\AppData\Local\Temp
else
	set directory=/tmp
endif
set backspace=2

" Jump to and show quickly to matching brace
set showmatch
set matchtime=2

" Show what you are typing
set showcmd

" Highlight search and search while typing
set hlsearch
set incsearch

" Look in all parent directories for ctags files
set tags=./tags;/

" Ignore the case when you search
"set ignorecase

" Move the cursor down on a split
set splitbelow

" Change to directory of working file
set autochdir

" Highlight current line
set cul

" Add command line completion
set wildmenu
set wildmode=list:longest,full

" Set English for spell-checking
if version >= 700
	set spl=en spell
	set nospell
endif

" Set to auto read when a file is changed from the outside
set autoread

set title
set t_Co=256
set laststatus=2
set noshowmode

" Set the clipboard to the system clipboard
if has("win32")
	set clipboard=unnamed
else
	set clipboard=unnamedplus
endif

" Set gui options
if has("gui_running")
	if has("win32")
		set guifont=Inconsolata_for_Powerline:h12:cANSI
	else
		set guifont=Inconsolata\ for\ Powerline\ Medium\ 12
	endif

	set background=dark

	set lines=70 columns=130

	colorscheme desert
else	
	colorscheme torte
endif

" Set folding
set foldcolumn=2
set foldmethod=syntax

syntax on
filetype plugin indent on

" Set relative line numbers with a gray color
set number
set relativenumber
set numberwidth=3
set cpoptions+=n
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

"========= KEY MAPPINGS

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

" Run love in current directory
map \l :! love .<CR>

" Clear search when enter is pressed
nnoremap <CR> :noh<CR><CR>

"========= FUNCTIONS

function! PythonFormatting()
	set expandtab
	set tabstop=4
	set softtabstop=4
	set shiftwidth=4
	set autoindent
	set textwidth=99
	set fileformat=unix
endfunction

" Save the file as sudo
if has("win32") == 0
	command! W w !sudo tee % > /dev/null
endif

" Git blame function to show the last edit of the line
function! Gblame(num)
	let l = a:firstline
	exe '!git blame -L' . (l-a:num) . ',' . (l+a:num) . ' % | sed "s/[^(]*(\([^)]*\).*/\1/"'
endfunction
command! -nargs=? Gblame :call Gblame("<args>")

" Remove trailing whitespace
func! DeleteTrailingWS()
	exe "normal mz"
	%s/\s\+$//ge
	exe "normal `z"
endfunc

if has("autocmd")
	" Reload vimrc when saved
	augroup myvimrc
		au!
		au BufWritePost .vimrc,_vimrc,vimrc source ~/.vimrc
	augroup END

	" Jump cursor to last known position
	au BufReadPost *
				\ if line("'\"") > 0 && line("'\"") <= line("$") |
				\   exe "normal g`\"" |
				\ endif

	" Don't unfold when editting a block
	au InsertEnter * let w:last_fdm=&foldmethod | setlocal foldmethod=manual
	au InsertLeave * let &l:foldmethod=w:last_fdm

	" Delete trailing white space on save, useful for Python and CoffeeScript
	au BufWrite *.py call DeleteTrailingWS()
	au BufWrite *.coffee call DeleteTrailingWS()

	" Set vim settings for Python
	au BufNewFile,BufReadPost *.py call PythonFormatting()

	" See XAML as XML
	au BufEnter,BufNewFile *.xaml setf xml

	au FileType xml setlocal tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
	au FileType cs setlocal tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

	au BufNewFile,BufRead *.md set filetype=markdown
	au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl set filetype=glsl
	au BufNewFile,BufRead SConstruct set filetype=python
endif

"========== ADDONS
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'vundlevim/vundle'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'scrooloose/syntastic'
Plugin 'ervandew/supertab'
Plugin 'mbbill/undotree'
Plugin 'tomasr/molokai'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'ryanss/vim-hackernews'
Plugin 'tpope/vim-dispatch'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'rust-lang/rust.vim'
Plugin 'Conque-GDB'
Plugin 'tikhomirov/vim-glsl'
Plugin 'justinmk/vim-syntax-extra'
Plugin 'airblade/gitgutter'
Plugin 'majutsushi/tagbar'
if has("win32")

else
	Plugin 'valloric/youcompleteme'
endif
call vundle#end()

" Ignore certain file extensions (used by Ctrl-P)
set wildignore+=*.o,*.la,*.lo,*.so

" Enable code completion (Ctrl-X Ctrl-O)
set omnifunc=syntaxcomplete#Complete

" Setup Ctrl-P
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

if has("persistent_undo")
	set undodir=C:\Users\thomas.versteeg\AppData\Local\Temp
	set undofile
endif

nnoremap <F5> :UndotreeToggle<cr>
nnoremap <F8> :TagbarToggle<cr>

"let g:molokai_original = 1
let g:rehash256 = 1
colorscheme molokai

let g:indent_guides_start_level = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 4

let g:airline_powerline_fonts = 1
let g:airline_theme='molokai'

let g:syntastic_python_pylint_post_args = '--disable=missing-docstring'

let g:syntastic_lua_checkers = ["luac", "luacheck"]
let g:syntastic_lua_luacheck_args = "--no-unused-args" 

if has("win32")
	let g:syntastic_cs_mcs_exec = 'C:\Program Files (x86)\Mono\bin\mcs'
	let g:syntastic_cs_mcs_args = "-checked"

	let g:syntastic_cs_checkers = ['mcs', 'syntax', 'semantic', 'issues']
else
	let g:syntastic_c_checkers=['make']
endif

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

if has("autocmd")
	au FileType xml let g:indent_guides_guide_size = 2
	au FileType xml IndentGuidesEnable
	if has("win32")
		au FileType xml setlocal equalprg=C:\bin\xmllint.exe\ --format\ -
	endif

	au FileType python setlocal formatprg=autopep8\ -

	au BufRead *.c,*.cpp,*h silent! :HighlightTags
endif
