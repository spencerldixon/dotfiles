" PLUGINS (Put all plugins in here)

call plug#begin()
Plug 'gmarik/Vundle.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'junegunn/goyo.vim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-rails'
Plug 'ap/vim-css-color'
Plug 'mattn/emmet-vim'
Plug 'jelera/vim-javascript-syntax'
Plug 'elixir-lang/vim-elixir'
Plug 'alexbel/vim-rubygems'
Plug 'mtscout6/vim-cjsx'
Plug 'w0ng/vim-hybrid'
Plug 'vim-syntastic/syntastic'
Plug 'junegunn/limelight.vim'
Plug 'prettier/vim-prettier'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mattn/webapi-vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}  " Conquer on completion
call plug#end()

" ESSENTIALS AND DEFAULTS (Color Scheme, Tab Spacing, etc.)

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

" set background=dark
colorscheme hybrid
set guifont=MesloLGL\ Nerd\ Font\ Mono
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

map <leader>e :NERDTreeToggle<CR>
let g:NERDTreeWinSize=38
let NERDTreeShowHidden=1
map <leader>r :NERDTreeFind<CR>
let g:NERDTreeWinPos = "left"

" AIRLINE CONFIG

let g:airline_theme='tomorrow'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show=1
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
let g:limelight_default_coefficient = 0.9
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

" FZF SETTINGS
nnoremap <leader>f :GFiles<CR>
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>t :Tags<CR>
nnoremap <Leader>s :Rg<CR>

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

" Node path for coc
let g:coc_node_path = "$HOME/.local/share/mise/installs/node/latest/bin/node"

" RUN PRETTIER ON SAVE

" nmap <Leader>py <Plug>(Prettier)
" let g:prettier#autoformat = 0
" autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue,*.yaml,*.html PrettierAsync
