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
set tabstop=2
set shiftwidth=2
set noexpandtab
set autoindent
set smartindent

" Set the directory for the ~ files
set directory=C:\Users\tve\AppData\Local\Temp
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

" Clear search when enter is pressed
nnoremap <CR> :noh<CR><CR>

" Change to directory of working file
set autochdir

" Highlight current line
set cul

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
set clipboard=unnamed

" Set gui options
if has("gui_running")
	set guifont=Inconsolata_for_Powerline:h12:cANSI
	set background=dark

	set lines=70 columns=130

	colorscheme desert
else
	" Enable the mouse in the commandline
	"if has('mouse')
	"	set mouse=a
	"endif

	colorscheme torte
endif

" Set folding
set foldcolumn=2
set foldmethod=syntax

syntax on
filetype off

" Set relative line numbers with a gray color
set number
set relativenumber
set numberwidth=3
set cpoptions+=n
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

" Ignore certain file extensions (used by Ctrl-P)
set wildignore+=*.o,*.la,*.lo,*.so

"========= KEY MAPPINGS

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

"========= FUNCTIONS

" Save the file as sudo
command! W w !sudo tee % > /dev/null

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
	au BufWrite *.py :call DeleteTrailingWS()
	au BufWrite *.coffee :call DeleteTrailingWS()
endif

"========== ADDONS
set rtp+=~/vimfiles/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'
Bundle 'ctrlpvim/ctrlp.vim'
Bundle 'Shutnik/jshint2.vim'
Bundle 'pangloss/vim-javascript'
Bundle 'scrooloose/syntastic'
Bundle 'othree/html5.vim'
Bundle 'ervandew/supertab'
Bundle 'mbbill/undotree'
Bundle 'tomasr/molokai'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'vim-airline/vim-airline'
Bundle 'vim-airline/vim-airline-themes'

" Setup Ctrl-P
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

let jshint2_command = 'C:\Users\tve\node_modules\.bin\jshint'
let jshint2_save = 1

if has("persistent_undo")
    set undodir=C:\Users\tve\AppData\Local\Temp
    set undofile
endif

nnoremap <F5> :UndotreeToggle<cr>

"let g:molokai_original = 1
let g:rehash256 = 1
colorscheme molokai

let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 4

let g:airline_powerline_fonts = 1
let g:airline_theme='molokai'

filetype plugin indent on
