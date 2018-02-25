" === Key bindings ===

if g:plugins_loading == 1
    Plug 'tpope/vim-sensible'                       " Apply general sensible defaults
endif

" === Buffers and files ===

if g:plugins_loading == 1
    Plug 'ctrlpvim/ctrlp.vim'                       " Sublime-style Ctrl-P file chooser
    Plug 'mhinz/vim-startify'                       " Welcome screen (bookmarks, MRU, etc.) when opening nvim by itself
    Plug 'tpope/vim-fugitive'                       " Git support
    Plug 'zefei/vim-wintabs'                        " Tab and window management
    Plug 'zefei/vim-wintabs-powerline'              " Use powerline rendering for wintabs
else
    let g:startify_relative_path=1
    let g:startify_update_oldfiles=1
    let g:startify_session_autoload=1
    let g:startify_session_persistence=1

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
endif

" === Nerdtree ===

if g:plugins_loading == 1
    Plug 'scrooloose/nerdtree'                      " Sidebar file browser
    "     ^ keep this before nerdtree-extending plugins
    Plug 'jistr/vim-nerdtree-tabs'                  " Keep tree a singleton
    Plug 'ryanoasis/vim-devicons'                   " Add file type specific 'icons' (needs a nerd font)
    Plug 'tiagofumo/vim-nerdtree-syntax-highlight'  " Colorize the devicons
    Plug 'Xuyuanp/nerdtree-git-plugin'              " Show git status in tree
else
    let g:NERDTreeMinimalUI=1
    let g:NERDTreeDirArrows=1
    let g:NERDTreeQuitOnOpen=1
    let g:NERDTreeAutoDeleteBuffer=1
endif

" === General editing ===

if g:plugins_loading == 1
    Plug 'easymotion/vim-easymotion'                " Keyed jump motion
    Plug 'editorconfig/editorconfig-vim'            " Tune editor settings with .editorconfig files
    " ^ TODO: use Plug feature to auto-install pip and editorconfig (maybe)
    " ^ TODO: need +python feature (pip install neovim) plus EditorConfig core
    Plug 'nacitar/terminalkeys.vim'                 " Fix keys when running nvim inside tmux (see https://sunaku.github.io/vim-256color-bce.html)
    Plug 'ntpeters/vim-better-whitespace'           " Highlight trailing whitespace
    Plug 'terryma/vim-multiple-cursors'             " Sublime-style multiple cursors
    Plug 'thaerkh/vim-indentguides'                 " Visually identify space `┆` and tab `|` indents
else
    let g:easymotion_do_mapping=0                   " disable default mappings
    let g:easymotion_smartcase=1                    " case sensitivity mode

    let g:EditorConfig_exclude_patterns = ['fugitive://.\*'] " recommended by EditorConfig-vim docs

    nmap <Leader>s <Plug>(easymotion-overwin-f2)    " two-char search motion
    map <Leader>l <Plug>(easymotion-lineforward)
    map <Leader>j <Plug>(easymotion-j)
    map <Leader>k <Plug>(easymotion-k)
    map <Leader>h <Plug>(easymotion-linebackward)
endif

" === Python ===

if g:plugins_loading == 1
    Plug 'numirias/vim-pytest'
    Plug 'klen/python-mode'                         " Python mode (docs, refactor, lints...)
    Plug 'hynek/vim-python-pep8-indent'
    Plug 'mitsuhiko/vim-python-combined'
    Plug 'jmcantrell/vim-virtualenv'
endif

    " === Appearance ===

if g:plugins_loading == 1
    Plug 'flazz/vim-colorschemes'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
else
    colorscheme Tomorrow-Night-Bright
    let g:airline_powerline_fonts=1
    let g:airline_theme='dark_minimal'

    " default airline uses old vim-powerline symbols, which apparently isn't in my font
    if !exists('g:airline_symbols') | let g:airline_symbols = {} | endif
    let g:airline_left_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_alt_sep = ''
    let g:airline_symbols.branch = ''
    let g:airline_symbols.readonly = ''
    let g:airline_symbols.linenr = '☰'
    let g:airline_symbols.maxlinenr = ''
endif


    "Plug 'mbbill/undotree'
    "let g:undotree_ShortIndicators=1
    "Plug 'tmhedberg/SimpylFold'
    "Plug 'w0rp/ale'
    "Plug 'majutsushi/tagbar'
    "Plug 'vim-ctrlspace/vim-ctrlspace'
    "Plug 'mileszs/ack.vim'
    "Plug 'fisadev/FixedTaskList.vim'
    "Plug 'yuttie/comfortable-motion.vim'
    "Plug 'MattesGroeger/vim-bookmarks'
    "Plug 'neomake/neomake'
    "Plug 'Shougo/deoplete.nvim'
    "Plug 'roxma/nvim-yarp'
    "Plug 'roxma/vim-hug-neovim-rpc'
    "Plug 'tpope/vim-surround'
    "Plug 'jreybert/vimagit'
    "Plug 'kien/rainbow_parentheses.vim'
    "Plug 'chriskempson/base16-vim'
    "Plug 'garbas/vim-snipmate'
    "Plug 'MarcWeber/vim-addon-mw-utils'
    "Plug 'tomtom/tlib_vim'
    "Plug 'honza/vim-snippets'
    "Plug 'scrooloose/nerdcommenter'

    "if g:plugins_loading == 1 && has('unix')
    "    Plug 'junegunn/fzf', { 'dir': '~/.local/share/fzf' }
    "    Plug 'junegunn/fzf.vim'
    "endif








