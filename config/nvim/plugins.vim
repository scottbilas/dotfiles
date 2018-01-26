Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'fholgado/minibufexpl.vim'
Plug 'flazz/vim-colorschemes'
Plug 'mbbill/undotree'
Plug 'mhinz/vim-startify'
Plug 'ntpeters/vim-better-whitespace'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'terryma/vim-multiple-cursors'
Plug 'tmhedberg/SimpylFold'
Plug 'tpope/vim-sensible'
Plug 'vim-airline/vim-airline'
Plug 'Xuyuanp/nerdtree-git-plugin'

if has("unix")
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
endif

" Must be after nerdtree related plugins above
Plug 'ryanoasis/vim-devicons'

let g:NERDTreeMinimalUI=1
let g:NERDTreeDirArrows=1
let g:NERDTreeDirArrowExpandable='+'
let g:NERDTreeDirArrowCollapsible='-'

let g:undotree_ShortIndicators=1

