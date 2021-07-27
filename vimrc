"""""""""""""""""""""
" Vim Addon Manager "
"""""""""""""""""""""

fun! EnsureVamIsOnDisk(plugin_root_dir)
    let vam_autoload_dir = a:plugin_root_dir.'/vim-addon-manager/autoload'
    if isdirectory(vam_autoload_dir)
        return 1
    else
        if 1 == confirm("Clone VAM into ".a:plugin_root_dir."?","&Y\n&N")
            call mkdir(a:plugin_root_dir, 'p')
            execute '!git clone --depth=1 git://github.com/MarcWeber/vim-addon-manager '.
                        \       shellescape(a:plugin_root_dir, 1).'/vim-addon-manager'
            exec 'helptags '.fnameescape(a:plugin_root_dir.'/vim-addon-manager/doc')
        endif
        return isdirectory(vam_autoload_dir)
    endif
endfun

fun! SetupVAM()
    let c = get(g:, 'vim_addon_manager', {})
    let g:vim_addon_manager = c
    let c.plugin_root_dir = expand('$HOME/.vim/vim-addons')

    if !EnsureVamIsOnDisk(c.plugin_root_dir)
        echohl ErrorMsg | echomsg "No VAM found!" | echohl NONE
        return
    endif

    let &rtp.=(empty(&rtp)?'':',').c.plugin_root_dir.'/vim-addon-manager'

    " Tell VAM which plugins to fetch & load:
    call vam#ActivateAddons([
                            \'commentary',
                            \'fugitive',
                            \'surround',
                            \'repeat',
                            \'fileline',
                            \'inkpot',
                            \'fontsize',
                            \'git:git://github.com/easymotion/vim-easymotion',
                            \'git:git://github.com/aykamko/vim-easymotion-segments',
                            \'git:git://github.com/PProvost/vim-ps1.git',
                            \'git:git://github.com/fatih/vim-go.git',
                            \], {'auto_install' : 0})
endfun

call SetupVAM()

" Vim: remap with 'map' by default
set remap

" Syntax highlighting
syntax on

" Colors
:set t_Co=256

" Indentation by file type
filetype plugin indent on

" not compatible with VI
set nocompatible

" 'normal' backspacing - delete a tab's worth if we're dealing with spaces
set backspace=2

" Tab stuffs
set tabstop=4
set shiftwidth=4
set smarttab
set shiftround
set expandtab
set smartindent

" Common indentation modes
" Sets the indentation options to common settings.
" Usage: :Tabs 8
"        :Spaces 3
"        :Tabs      " same as Tabs 8
"        :Spaces    " same as Spaces 4
command! -bar -count=8 Tabs set ts=<count> sts=0 sw=<count> noet
command! -bar -count=4 Spaces set ts=8 sts=<count> sw=<count> et

" allow modelines
set modeline

" search at most 1 line for modelines (for top or bottom?)
set modelines=2

" show the ruler on the last line
set ruler

" sed commands have /g by default
set gdefault

" Unicode
if has('multi_byte')
    if &termencoding == ""
        let &termencoding = &encoding
    endif
    set encoding=utf-8
    setglobal fileencoding=utf-8
    set fileencodings=ucs-bom,utf-8,latin1
endif

" Send swap files to a temporary dir, make the swp file names unique by dir
if has('unix')
    set directory=/tmp//,/var/tmp//
else
    set directory=C:\\Temp\\vim//
endif

" Always a buffer of 3 lines between the cursor and the top / bottom
set scrolloff=3

" Column guide
set cc=81

" Shows menu based on autocomplete
set wildmenu
set wildmode=full

" Speed boost
set ttyfast

" Smarter searching
set ignorecase
set smartcase
set incsearch
" Highlight all search matches
set hlsearch

" Stupid shift mistakes.
:command W w
:command Q q
:command WQ wq
:command Wq wq

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

""""""""""""""""""""""
" Mapleader bindings "
""""""""""""""""""""""
" Rebind <leader> to ","
let mapleader = ","

" Clears highlighting after a search
nnoremap <leader><space> :noh<cr>

" Toggle highlighting of the last search.
noremap <leader>h :set hlsearch! hlsearch?<CR>

" Toggle between relative and not
noremap <leader>r :set relativenumber! relativenumber?<CR>

" Toggle list characters
set list
let s:list_on=1
function! ToggleList()
    if s:list_on == '1'
        let s:list_on = 0
        set listchars=""
        set listchars=trail:.,tab:>-
    else
        let s:list_on = 1
        set listchars=""
        set listchars=eol:$,tab:>-
    endif
endfunction
call ToggleList()

noremap <Leader>l :call ToggleList()<CR>

" Toggle list on / off
noremap <Leader>L :set list!<CR>

" Toggling mouse...
noremap <Leader>m :exec &mouse == "a" ? ":set mouse=" : ":set mouse=a"<CR>

" Toggle paste mode.
noremap <Leader>p :set paste!<CR>

" strip all trailing whitespace in current file
fun! StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd FileType * autocmd BufWritePre <buffer> :call StripTrailingWhitespaces()

nnoremap <leader>W :call StripTrailingWhitespaces()<CR>

" Insert a tab character (even when spaces are the tab mode)
nnoremap <leader><Tab> i<c-v><Tab><ESC>

" Line numbers
set number

""""""""""""""
" Navigation "
""""""""""""""

" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Going cold turkey on the arrow keys
map <up> <Nop>
map <down> <Nop>
map <left> <Nop>
map <right> <Nop>

" Make j and k react better on wrapped lines
noremap j gj
noremap k gk

" Make Y behave like other capitals - copy from cursor to EOL, not whole line
nnoremap Y y$

inoremap jj <Esc>

" Enable the mouse for clicking, scrolling, selecting, etc
set mouse=a

" EasyMotion
if ! exists('g:in_vsvim')
    map  / <Plug>(easymotion-sn)
    omap / <Plug>(easymotion-tn)

    omap t <Plug>(easymotion-bd-tl)

    let g:EasyMotion_use_upper = 1
    let g:EasyMotion_smartcase = 1

    " EasyMotion Segments
    map <leader>w <Plug>(easymotion-segments-LF)
    map <leader>b <Plug>(easymotion-segments-LB)
    map <leader>e <Plug>(easymotion-segments-RF)
    map <leader>B <Plug>(easymotion-segments-RB)
endif

" Read local-machine-only settings
let localrc = $HOME . '/.vimrclocal'
if (filereadable(localrc))
    exec ('source ' . localrc)
endif

colorscheme inkpot

" Change behavior of *,g* so * searches for the word under the cursor anywhere
" instead of just as a whole word. Also, strip trailing dash from word so a
" search with cursor on $blah->blah() still finds $blah (and the reverse)
noremap * :call SearchCurrentWord()<CR>

function! SearchCurrentWord()
    " Strip dash from end of word
    let cur_word = substitute(expand("<cword>"), '-$','','')
    let @/ = cur_word
    set hlsearch
    normal n
endfunction

if (has('unix') && !has('macunix'))
    set clipboard=unnamedplus
endif

" Go
let g:go_fmt_command = 'goimports'

