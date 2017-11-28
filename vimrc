" RUNTIME (set the runtime path to include Vundle and initialize)
set rtp+=~/.vim/bundle/Vundle.vim

" PLUGINS (Put all plugins in here)
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Bundle 'jlanzarotta/bufexplorer'
Plugin 'bling/vim-airline.git'
Plugin 'scrooloose/nerdtree.git'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-fugitive'
Plugin 'kien/ctrlp.vim'
Plugin 'junegunn/goyo.vim'
Plugin 'junegunn/limelight.vim'
Plugin 'paranoida/vim-airlineish'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-rails'
Plugin 'ap/vim-css-color'
Plugin 'mattn/emmet-vim'
Plugin 'tpope/vim-obsession'
Plugin 'jelera/vim-javascript-syntax'
Plugin 'chriskempson/base16-vim'
Plugin 'morhetz/gruvbox'
Plugin 'elixir-lang/vim-elixir'
Plugin 'mattn/webapi-vim'
Plugin 'alexbel/vim-rubygems'
Plugin 'kchmck/vim-coffee-script'
Plugin 'w0ng/vim-hybrid'
Plugin 'lucidstack/ctrlp-tmux.vim'
Plugin 'mtscout6/vim-cjsx'
Plugin 'vim-scripts/TaskList.vim'
call vundle#end()

"Follow this tutorial for installation
" http://blog.smalleycreative.com/tutorials/using-git-and-github-to-manage-your-dotfiles/

" SET DEFAULTS (Color Scheme, Tab Spacing, etc.)
set nocompatible
filetype off
set undofile
set cursorline
set laststatus=2
set mouse=a
set encoding=utf-8
set tabstop=2
set shiftwidth=2
set expandtab
set title
au BufWritePost .vimrc so ~/.vimrc " (automatically reload vimrc when it's saved)
set number
set numberwidth=3
set guifont=Menlo\ For\ Powerline
set ignorecase
set smartcase
set incsearch
set hlsearch
set showmatch
set nobackup
set noswapfile
syntax enable
set relativenumber
set timeoutlen=1000 ttimeoutlen=0
set background=dark
colorscheme hybrid
"gruvbox "heroku-monokai

" Use neocomplete.vim
let g:neocomplete#sources#omni#input_patterns = {
\   "ruby" : '[^. *\t]\.\w*\|\h\w*::',
\}

" Set leader to spacebar
let mapleader = "\<Space>"
let g:mapleader = "\<Space>"

" Fast reload of vimrc
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" Strip trailing whitespaces on save
autocmd BufWritePre * :%s/\s\+$//e

" Go to end of file with Enter
nmap <CR> G
" Beginning of file with Backspace
nmap <BS> gg
nmap <leader>w :w<CR>

filetype plugin indent on

" VIM KEYMAPPINGS
nnoremap <leader>p :bp<CR>
nnoremap <leader>n :bn<CR>
nnoremap <tab>   <C-w>w
nnoremap <leader>d :bd<CR>

" POWERLINE CONFIG
let g:airline_powerline_fonts = 1
let g:airline_theme           = 'tomorrow'  "'gruvbox'
let g:airline#extensions#tabline#enabled = 1

" CUSTOM AIRLINE CONFIG
let g:airline_section_a = airline#section#create(['mode', ' ', 'branch'])
let g:airline_section_b = airline#section#create(['%F', ' ', '%m'])
let g:airline_section_c = ''
let g:airline_section_x = airline#section#create(['Line ', '%l', ' of ', '%L'])
let g:airline_section_y = airline#section#create(['mode', ' ', 'branch'])
let g:airline_section_z = '%{strftime("%I:%M")}'

" GOYO CONCENTRATION MODE
let g:goyo_width = 120
nnoremap <silent> <leader>z :Goyo<cr>

" LIMELIGHT
nmap <Leader>l :Limelight!!<CR>
let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240
let g:limelight_conceal_guifg = 'DarkGray'
let g:limelight_conceal_guifg = '#777777'
let g:limelight_default_coefficient = 0.7
let g:limelight_paragraph_span = 0

" NERDTREE CONFIG
map <C-n> :NERDTreeToggle<CR>
let g:NERDTreeWinSize=38
let NERDTreeShowHidden=1
map <leader>r :NERDTreeFind<CR>
" autocmd VimEnter * if argc() == 0 | NERDTree | endif

" CTRLP CONFIG - Vim Search/Finder
set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:20,results:20'
let g:ctrlp_cmd = 'CtrlPLastMode'
let g:ctrlp_extensions = ['buffertag', 'tag', 'line', 'dir', 'tmux']
nnoremap <leader>f :CtrlP<CR>
nnoremap <S-r> :CtrlPMRUFiles<CR>
nnoremap <Leader>s :CtrlPTmux<CR>

" SILVER SEARCH CONFIG
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif
command! -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
nnoremap \ :Ag<SPACE>
nmap <silent> <up> :cprev<CR>
nmap <silent> <down> :cnext<CR>

" EMMETT CONFIG
let g:user_emmet_leader_key=','

" transparent background
highlight Normal  ctermbg=none
highlight NonText ctermbg=none

" APPEND RECENT GEM VERSION TO GEM WITH SPACE + G
nnoremap <leader>g :RubygemsAppendVersion<cr>

" SYNTASTIC
let g:syntastic_coffee_checkers = ['coffeelint']

" Shared clipboard with osx
if has('mac')
  set clipboard=unnamed
end

