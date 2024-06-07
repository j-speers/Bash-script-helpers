" Jordans Neovim configuration to make editing and searching through files
" More pleasant and efficient

" Get the defaults that most users want.
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" if has("vms")
set nobackup          " do not keep a backup file, use versions instead
" else
"   set backup            " keep a backup file (restore to previous version)
"   if has('persistent_undo')
"     set undofile        " keep an undo file (undo changes after closing)
"   endif
" endif

" Add optional packages.
if has('syntax') && has('eval')
  packadd! matchit
endif

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

"Auto Indent On
set ai

" Add numbers to each line on the left-hand side.
" set number

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" Highlight cursor line underneath the cursor vertically.
set cursorcolumn

" Set shift width to 4 spaces.
set shiftwidth=2

" Set tab width to 4 columns.
set tabstop=2

" Use space characters instead of tabs.
set expandtab

" Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=5

" [Disabled] Do not wrap lines. Allow long lines to extend as far as the line goes.
"set nowrap

" Ignore capital letters during search.
set ignorecase

" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Set the commands to save in history default number is 20.
set history=10000

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" Dark mode enjoyer
set background=dark

" 256 bit colour support
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" PLUGINS ---------------------------------------------------------------- {{{

call plug#begin('/root/.local/share/nvim/site/plugged')

  Plug 'itchyny/lightline.vim'

  Plug 'morhetz/gruvbox'
call plug#end()
" }}}

" VIMSCRIPT -------------------------------------------------------------- {{{

" VIM Code Functions
" Enable Gruvbox Theme
augroup theme_vim
  au!
  autocmd vimenter * ++nested colorscheme gruvbox
augroup END

" This will enable code folding.
" Use the marker method of folding.
augroup filetype_vim
    autocmd!
    autocmd FileType text setlocal textwidth=100
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" }}}

" STATUS LINE ------------------------------------------------------------ {{{

" Ensure status line at bottom gets rendered
set laststatus=2

" }}}
