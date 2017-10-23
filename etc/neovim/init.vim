" Brief help
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install(update) bundles
" :BundleSearch(!) foo - search(or refresh cache first) for foo
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed..
"
set nocompatible " be iMproved
filetype off " required!
filetype plugin indent on " required!

set rtp+=~/.config/nvim/bundle/vundle/
call vundle#rc()

" Vundle manages itself (required!)
Bundle 'gmarik/vundle'

" Theming Repos
Bundle 'ngty/Wombat'
Bundle 'NLKNguyen/papercolor-theme'

" Github Repos
Bundle 'tpope/vim-fugitive'
Bundle 'benekastah/neomake'

" Other git repos
"Bundle 'git://git.wincent.com/command-t.git'

" VIM-scripts repos
Bundle 'rails.vim'
Bundle 'CSApprox'
Bundle 'easymotion/vim-easymotion'
Bundle 'tComment'
Bundle 'junegunn/fzf'
Bundle 'junegunn/fzf.vim'

" *easymotion* tweaks (see https://github.com/easymotion/vim-easymotion)
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
map <Leader> <Plug>(easymotion-prefix)
map <Leader>l <Plug>(easymotion-lineforward)
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>h <Plug>(easymotion-linebackward)
let g:EasyMotion_startofline = 0 " keep cursor column when JK motion
let g:EasyMotion_smartcase = 1

" Split view navigating
noremap <silent> <C-K> :wincmd k<CR>
noremap <silent> <C-J> :wincmd j<CR>
noremap <silent> <C-H> :wincmd h<CR>
noremap <silent> <C-L> :wincmd l<CR>

" Theming
syntax enable
syntax on
"colorscheme wombat
set background=light
set t_Co=256
set number
set laststatus=2
colorscheme PaperColor
let g:airline_theme='papercolor'
let g:lightline = { 'colorscheme': 'PaperColor' }

" PaperColor specific
" let g:PaperColor_Theme_Options = {
"   \   'theme': {
"   \     'default.dark': { 
"   \       'override' : {
"   \         'color00' : ['#080808', '232'],
"   \         'linenumber_bg' : ['#080808', '232']
"   \       }
"   \     }
"   \   }
"   \ }

" Tabbing
set expandtab
set smarttab
set softtabstop=2
set tabstop=2
set shiftwidth=2

" Turn off backup
set nobackup
set nowritebackup
set noswapfile

" Encoding
set encoding=utf-8
set fileencoding=utf-8

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Misc appearance
set number
set colorcolumn=80
set ruler
set nowrap

" Indenting
set autoindent
set smartindent

" Disable mouse
set mouse-=a

" Backspacing
set backspace=indent,eol,start

" History
set viminfo='20,\"1000 "
set history=50

" Undos
set undofile
set undodir=~/.vim/undo
set undolevels=1000 
set undoreload=10000

" Linting
let g:neomake_verbose=3
let g:neomake_open_list=2
let g:neomake_javascript_enabled_makers = ['eslint']

autocmd! BufWritePost,BufEnter * Neomake

" __END__
