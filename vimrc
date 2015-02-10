" Follow this tutorial for installation
" http://blog.smalleycreative.com/tutorials/using-git-and-github-to-manage-your-dotfiles/

" SET DEFAULTS (Color Scheme, Tab Spacing, etc.)
set nocompatible
filetype off
set cursorline
set laststatus=2
set mouse=a
set encoding=utf-8
set tabstop=2
set shiftwidth=2
set expandtab
au BufWritePost .vimrc so ~/.vimrc " (automatically reload vimrc when it's saved)
set autochdir
set number
set numberwidth=2
set guifont=Menlo\ For\ Powerline

syntax enable
set background=dark
colorscheme benokai



" RUNTIME (set the runtime path to include Vundle and initialize)
set rtp+=~/.vim/bundle/Vundle.vim
 
" PLUGINS (Put all plugins in here)
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Bundle 'jlanzarotta/bufexplorer'
Plugin 'bling/vim-airline.git'
Plugin 'scrooloose/nerdtree.git'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'tpope/vim-fugitive'
Plugin 'kien/ctrlp.vim'
call vundle#end()

filetype plugin indent on

" VIM KEYMAPPINGS
nnoremap <S-Left> :bp<CR>
nnoremap <S-Right> :bn<CR>
nnoremap <tab>   <C-w>w
nnoremap <S—d>	:bd<CR>

" POWERLINE CONFIG
let g:airline_powerline_fonts = 1
let g:airline_theme           = 'base16'
let g:airline#extensions#tabline#enabled = 1

" NERDTREE CONFIG
" let NERDTreeShowHidden=0
" autocmd vimenter * NERDTree
map <C-n> :NERDTreeToggle<CR>

" CTRLP CONFIG - Vim Search/Finder
set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_map = '<S-f>'
nnoremap <S-r> :CtrlPMRUFiles<CR>
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:20,results:20'
let g:ctrlp_cmd = 'CtrlPLastMode'
let g:ctrlp_extensions = ['buffertag', 'tag', 'line', 'dir']


