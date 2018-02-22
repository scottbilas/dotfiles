Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'fholgado/minibufexpl.vim'
Plug 'flazz/vim-colorschemes'
Plug 'mbbill/undotree'
Plug 'mhinz/vim-startify'
Plug 'ntpeters/vim-better-whitespace'
Plug 'terryma/vim-multiple-cursors'
Plug 'tmhedberg/SimpylFold'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'vim-airline/vim-airline'
Plug 'w0rp/ale'

" Nerdtree
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'jistr/vim-nerdtree-tabs'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'

if has("unix")
    Plug 'junegunn/fzf', { 'dir': '~/.local/share/fzf' }
    Plug 'junegunn/fzf.vim'
endif

let g:startify_bookmarks = [
    \ { 'c': '~/.config/nvim/init.vim' }
    \ ]

let g:startify_custom_header = [
    \ '      ,*        *.',
    \ '    ,****       *//.',
    \ '   ////***,     *////.                                          ###',
    \ '   ////*****    *////.     /  ((*     ,((/      (((.  %%.    #%/#%# #%,*%%# .#%%#.',
    \ '   ////******   *((((,     %     (  //     # .(     #,.%%   (%# #%# #%%   %%%   %%',
    \ '   ////..*****. *((((,     %     ., %######% %       % *%%  %%  #%# #%#   %%/   %%',
    \ '   ((((.  *****/*((((,     %     ., %        %       %  #%,%%   #%# #%#   %%/   %%',
    \ '   ((((.   */////((((,     %     .,  %     ,  #     %    %%%.   #%# #%#   %%/   %%',
    \ '   ((((.    ,////((((,',
    \ '   /(((.      //((((*',
    \ '     /(.       /((*',
    \ ]

let g:startify_relative_path=1
let g:startify_update_oldfiles=1
let g:startify_session_autoload=1
let g:startify_session_persistence=1

let g:NERDTreeMinimalUI=1
let g:NERDTreeDirArrows=1
let g:NERDTreeQuitOnOpen=1
let g:NERDTreeAutoDeleteBuffer=1

let g:undotree_ShortIndicators=1

