" Reset to vim-defaults
if &compatible
	set nocompatible
endif

execute pathogen#infect()

" Set the tabsizes and behavior
set tabstop=2
set shiftwidth=2
set noexpandtab
set autoindent
set smartindent

" Set the directory for the ~ files
set directory=/tmp

" Jump quickly to matching brace
set showmatch
set matchtime=2

" Show what you are typing
set showcmd

" Highlight search and search while typing
set hlsearch
set incsearch

" Clear search when enter is pressed
nnoremap <CR> :noh<CR><CR>

" Change to directory of working file
set autochdir

" Highlight current line
set cul

" Set English for spell-checking
if version >= 700
	set spl=en spell
endif

set title
set t_Co=256
set laststatus=2
set noshowmode
set clipboard=unnamedplus

" Set gui options
if has("gui_running")
	set guifont=Terminus\ 9
	set background=dark

	colorscheme desert
else
	colorscheme torte
endif

" Set folding
set foldcolumn=2
set foldmethod=syntax

syntax on
filetype plugin indent on

let g:EclimCompletionMethod = 'omnifunc'

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

if has("autocmd")
	au BufNewFile,BufRead *.java set foldlevel=1
	au BufNewFile,BufRead *.java :Validate
	au BufNewFile,Bufread *.gradle set filetype=groovy
	au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl set filetype=glsl
	au BufNewFile,BufRead SConstruct set filetype=python
	au BufNewFile,BufRead sxhkdrc,*.sxhkdrc set filetype=sxhkdrc

	" Reload vimrc when saved
	augroup myvimrc
		au!
		au BufWritePost .vimrc,_vimrc,vimrc source ~/.vimrc
	augroup END

	" Don't unfold when editting a block
	au InsertEnter * let w:last_fdm=&foldmethod | setlocal foldmethod=manual
	au InsertLeave * let &l:foldmethod=w:last_fdm

	" Jump cursor to last known position
	au BufReadPost * 
	\ if line("'\"") > 0 && line("'\"") <= line("$") | 
	\   exe "normal g`\"" | 
	\ endif 
endif
