" RUNTIME (set the runtime path to include Vundle and initialize)

set rtp+=~/.vim/bundle/Vundle.vim


" PLUGINS (Put all plugins in here)

call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'itchyny/lightline.vim'
Plugin 'bling/vim-bufferline'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'scrooloose/nerdtree.git'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-fugitive'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'junegunn/goyo.vim'
Plugin 'airblade/vim-gitgutter'
Plugin 'tpope/vim-rails'
Plugin 'ap/vim-css-color'
Plugin 'mattn/emmet-vim'
Plugin 'jelera/vim-javascript-syntax'
Plugin 'elixir-lang/vim-elixir'
Plugin 'alexbel/vim-rubygems'
Plugin 'kchmck/vim-coffee-script'
Plugin 'lucidstack/ctrlp-tmux.vim'
Plugin 'mtscout6/vim-cjsx'
Plugin 'w0ng/vim-hybrid'
Plugin 'vim-syntastic/syntastic'
Plugin 'junegunn/limelight.vim'
Plugin 'mattn/webapi-vim'
Plugin 'posva/vim-vue'
Plugin 'tomlion/vim-solidity'
Plugin 'prettier/vim-prettier'
call vundle#end()

" ESSENTIALS AND DEFAILTS (Color Scheme, Tab Spacing, etc.)

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
set ignorecase
set smartcase
set incsearch
set hlsearch
set showmatch
set nobackup
set noswapfile
syntax enable
" set relativenumber
set timeoutlen=1000 ttimeoutlen=0

" Shared clipboard with osx
set clipboard=unnamed


" COLOURSCHEME

set background=dark
colorscheme hybrid
set guifont=Menlo\ For\ Powerline
let g:hybrid_custom_term_colors = 1


" NAVIGATION

" Set leader to spacebar
let mapleader = "\<Space>"
let g:mapleader = "\<Space>"

" Fast reload of vimrc
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" copy and paste to from system clipboard
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P


" Strip trailing whitespaces on save
autocmd BufWritePre * :%s/\s\+$//e

" Go to end of file with Enter
nmap <CR> G

" Beginning of file with Backspace
nmap <BS> gg

" Quick write
nmap <leader>w :w<CR>

filetype plugin indent on

" Keymappings
nnoremap <leader>p :bp<CR> " Previous buffer
nnoremap <leader>n :bn<CR> " Next buffer
nnoremap <leader>d :bd<CR> " Delete buffer
nnoremap <tab> <C-w>w


" NERDTREE CONFIG

map <C-n> :NERDTreeToggle<CR>
let g:NERDTreeWinSize=38
let NERDTreeShowHidden=1
map <leader>r :NERDTreeFind<CR>
let g:NERDTreeWinPos = "left"

" AIRLINE CONFIG

let g:airline_theme='tomorrow'
let g:airline#extensions#tabline#enabled = 1
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
let g:limelight_conceal_guifg = '#777777 '
let g:limelight_default_coefficient = 0.7
let g:limelight_paragraph_span = 0

autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!


" NERDCOMMENTER SETTINGS

" Add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1

" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1

" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1


" CTRL P SETTINGS

set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:20,results:20'
let g:ctrlp_cmd = 'CtrlPLastMode'
let g:ctrlp_extensions = ['buffertag', 'tag', 'line', 'dir', 'tmux']
nnoremap <leader>f :CtrlP<CR>
nnoremap <S-r> :CtrlPMRUFiles<CR>
nnoremap <Leader>s :CtrlPTmux<CR>

" EMMETT CONFIG

let g:user_emmet_leader_key=','


" APPEND RECENT GEM VERSION TO GEM WITH SPACE + G

nnoremap <leader>g :RubygemsAppendVersion<cr>

" SYNTASTIC CONFIG

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_coffee_checkers = ['coffeelint']
let g:syntastic_python_checkers = ['python']

" RUN PRETTIER ON SAVE
" nmap <Leader>py <Plug>(Prettier)
" let g:prettier#autoformat = 0
" autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync
