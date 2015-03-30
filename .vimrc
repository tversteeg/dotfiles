execute pathogen#infect()

set tabstop=2
set shiftwidth=2
set noexpandtab
set autoindent
set smartindent
set directory=/tmp
set nocompatible
set title
set t_Co=256
set background=dark
set laststatus=2
set noshowmode
set clipboard=unnamedplus
set guifont=Inconsolata\ 14

"colorscheme desert
colorscheme torte
syntax on
filetype plugin indent on

let g:EclimCompletionMethod = 'omnifunc'

:nmap \d :JavaDocComment<CR>
:nmap \h :JavaHierarchy<CR>
:nmap \c :JavaCorrect<CR>
:nmap \p :JavaDocPreview<CR>
:nmap \f :%JavaFormat<CR>
:vmap \f :JavaFormat<CR>
:nmap \i :JavaImportOrganize<CR>
:vmap \i :JavaImport<CR>
:nmap \s :JavaSearch<CR>
:vmap \s :JavaSearch<CR>
:nmap \r :JavaSearch -x references<CR>
:vmap \r :JavaSearch -x references<CR>
:nmap \g :JavaGetSet<CR>
:vmap \g :JavaGetSet<CR>

function! Gblame(num)
  let l = a:firstline
  exe '!git blame -L' . (l-a:num) . ',' . (l+a:num) . ' % | sed "s/[^(]*(\([^)]*\).*/\1/"'
endfunction
command! -nargs=? Gblame :call Gblame("<args>")

au BufRead,BufNewFile *.java :Validate
au BufRead,BufNewFile *.gradle set filetype=groovy
au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl set filetype=glsl
au BufNewFile,BufRead SConstruct set filetype=python
au BufNewFile,BufRead sxhkdrc,*.sxhkdrc set filetype=sxhkdrc

" Reload vimrc when saved
augroup myvimrc
	au!
	au BufWritePost .vimrc,_vimrc,vimrc source ~/.vimrc
augroup END

" Change to directory of file
autocmd BufEnter * lcd %:p:h

" Jump cursor to last known position
autocmd BufReadPost * 
\ if line("'\"") > 0 && line("'\"") <= line("$") | 
\   exe "normal g`\"" | 
\ endif 
