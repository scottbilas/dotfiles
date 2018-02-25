" === General ===

set number                      "Line numbers are good
set backspace=indent,eol,start  "Allow backspace in insert mode
set history=1000                "Store lots of :cmdline history
set showcmd                     "Show incomplete cmds down the bottom
set showmode                    "Show current mode down the bottom
set gcr=a:blinkon0              "Disable cursor blink
set visualbell                  "No sounds
set autoread                    "Reload files changed outside vim
set title                       "Terminal should inherit vim title
set encoding=utf8               "Needed to show glyphs
set switchbuf=usetab,newtab     "Try to reuse existing tab with already-open buffer, otherwise open new tab for it

" This makes vim act like all other editors, buffers can
" exist in the background without being in a window.
" http://items.sjbach.com/319/configuring-vim-right
set hidden

syntax on

" Change leader to a comma because the backslash is too far away
" That means all \x commands turn into ,x
" The mapleader has to be set before loading all the plugins.
let mapleader=","

" The % key will switch between opening and closing brackets. By sourcing
" matchit.vim — a standard file in Vim installations for years — the key can
" also switch among e.g. if/elsif/else/end, between opening and closing XML
" tags, and more.
runtime macros/matchit.vim

" === Plugins ===

" TODO: auto create pip venv and `pip install neovim` into it
let g:python3_host_prog=glob('~/.local/share/nvim/venv/bin/python')

" auto download vim-plug and activate it
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

if has("win32")
  source ~/.local/share/nvim/site/autoload/plug.vim " can't get autoload to work on windows
endif

let g:plugins_loading=1 " this lets me keep plugin-specific settings right next to the plugin being selected
call plug#begin('~/.local/share/nvim/plugged')
source ~/.config/nvim/plugins.vim
call plug#end()
let g:plugins_loading=0
source ~/.config/nvim/plugins.vim

" === Backup ===

set noswapfile

" Keep undo history across sessions, by storing in file. Only works all the time.
if has('persistent_undo')
  if !isdirectory(expand('~').'/.cache/nvim/backups')
    silent !mkdir -p ~/.local/share/nvim/backups > /dev/null 2>&1
  endif
  set undodir=~/.local/share/nvim/backups
  set undofile
  set nobackup
  set nowb
endif

" === Horizontal ===

set autoindent
set smartindent
set smarttab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set expandtab

" Auto indent pasted text
nnoremap p p=`]<C-o>
nnoremap P P=`]<C-o>

set nowrap          "Don't wrap lines
set linebreak       "Wrap lines at convenient points
set nofoldenable    "Dont fold by default

" Enable folding with the spacebar
nnoremap <space> za

" Show column guides
if (exists('+colorcolumn'))
    set colorcolumn=120
    highlight ColorColumn ctermbg=darkgray
endif

" === Scrolling ===

set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

" === Search and Completion ===

set ignorecase
set smartcase
set infercase

" === Other ===

" Auto-reload vimrc on save
augroup reload_vimrc " {
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
    autocmd BufWritePost plugins.vim source $MYVIMRC
augroup END " }

