" Reset to vim-defaults
if &compatible
	set nocompatible
endif

execute pathogen#infect()
execute pathogen#helptags()

" Load Ctrl-P
set runtimepath^=~/.vim/bundle/ctrlp.vim

" Set the tabsizes and behavior
set tabstop=2
set shiftwidth=2
set noexpandtab
set autoindent
set smartindent

" Set the directory for the ~ files
set directory=/tmp

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

" Save the file as sudo
command! W w !sudo tee % > /dev/null

set title
set t_Co=256
set laststatus=2
set noshowmode

" Set the clipboard to the system clipboard
set clipboard=unnamedplus

" Set gui options
if has("gui_running")
	set guifont=Terminus\ 9,Monospace\ 10
	set background=dark

	set lines=50 columns=120

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
filetype plugin indent on

" Set relative line numbers with a gray color
set number
set relativenumber
set numberwidth=3
set cpoptions+=n
highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=NONE gui=NONE guifg=DarkGrey guibg=NONE

" Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

nmap \d :JavaDocComment<CR>
nmap \h :JavaHierarchy<CR>
nmap \c :JavaCorrect<CR>
nmap \p :JavaDocPreview<CR>
nmap \f :%JavaFormat<CR>
vmap \f :JavaFormat<CR>
nmap \i :JavaImportOrganize<CR>
vmap \i :JavaImport<CR>
nmap \s :JavaSearch<CR>
vmap \s :JavaSearch<CR>
nmap \r :JavaSearch -x references<CR>
vmap \r :JavaSearch -x references<CR>
nmap \g :JavaGetSet<CR>
vmap \g :JavaGetSet<CR>

nmap \n :NERDTreeFind<CR>
nmap \m :NERDTreeToggle<CR>

function! Gblame(num)
	let l = a:firstline
	exe '!git blame -L' . (l-a:num) . ',' . (l+a:num) . ' % | sed "s/[^(]*(\([^)]*\).*/\1/"'
endfunction
command! -nargs=? Gblame :call Gblame("<args>")

" Ignore certain files in NERDTree
let NERDTreeIgnore = ['\.o$', '\.lo$', '\.swp$', '\.zip$', '\.swo$']

" Display folders always on top followed by specified files
let NERDTreeSortOrder = ['\/$', '\.sh$', '\.h$', '\.c$']

" Remap the YCM invoke key
let g:ycm_key_invoke_completion = '\y'

" Remove conflicts between YCM & Eclim
let g:EclimCompletionMethod = 'omnifunc'

" Automatically refresh easytags highlighting on save
let g:easytags_events = ['BufWritePost']

" Also include struct members
let g:easytags_include_members = 1

" Setup Ctrl-P
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

" Setup Syntastic for Haskell
map <Leader>s :SyntasticToggleMode<CR>

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

if has("autocmd")
	au BufNewFile,BufRead *.java set nofoldenable
	au BufNewFile,BufRead *.java :Validate
	au BufNewFile,Bufread *.gradle set filetype=groovy
	au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl set filetype=glsl
	au BufNewFile,BufRead SConstruct set filetype=python
	au BufNewFile,BufRead sxhkdrc,*.sxhkdrc set filetype=sxhkdrc
	au BufNewFile,BufRead *.md set filetype=markdown
	au BufNewFile,Bufread *.sbot set filetype=javascript.awk
	au BufNewFile,BufRead *.sbot set nofoldenable

	" Reload vimrc when saved
	augroup myvimrc
		au!
		au BufWritePost .vimrc,_vimrc,vimrc source ~/.vimrc
	augroup END

	" Load NERDTree on startup
	au VimEnter * NERDTree

	" Close NERDTree when it's the only window
	au BufEnter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

	" Don't unfold when editting a block
	au InsertEnter * let w:last_fdm=&foldmethod | setlocal foldmethod=manual
	au InsertLeave * let &l:foldmethod=w:last_fdm

	" Jump cursor to last known position
	au BufReadPost * 
				\ if line("'\"") > 0 && line("'\"") <= line("$") | 
				\   exe "normal g`\"" | 
				\ endif 

	" Delete trailing white space on save, useful for Python and CoffeeScript
	func! DeleteTrailingWS()
	exe "normal mz"
	%s/\s\+$//ge
	exe "normal `z"
	endfunc
	au BufWrite *.py :call DeleteTrailingWS()
	au BufWrite *.coffee :call DeleteTrailingWS()

	" Refresh the ctags, not needed because of easytags
	au BufWritePost *.c,*.cpp,*.h silent! !ctags -R &
	
	" Apply easytags highlighting, easytags handles the refreshes itself
	au BufRead *.c,*.cpp,*h silent! :HighlightTags
endif
