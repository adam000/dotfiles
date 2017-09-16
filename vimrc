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
                            \], {'auto_install' : 0})
                            "\'EasyMotion',
                            "\'UltiSnips',
                            "\'abolish',
                            "\'Gundo',
                            "\'Conque_Shell',
                            "\'vim-powerline',
                            "\'Solarized',
endfun

call SetupVAM()

" Syntax highlighting
syntax on

" Colors
:set t_Co=256

" Indentation by file type
filetype plugin indent on

" Gundo
nnoremap <F5> :GundoToggle<CR>

" not compatible with VI
set nocompatible

" 'normal' backspacing
set bs=2

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
set mls=1

" Always show statusline (due to powerline plugin's usefulness)
set ls=2

" show the ruler on the last line
set ruler

" sed commands have /g by default
set gdefault

" Go's vim files
set rtp+=$GOROOT/misc/vim

" F1 doesn't show help
nnoremap <F1> <Nop>
inoremap <F1> <Nop>
vnoremap <F1> <Nop>

" Unicode
if has("multi_byte")
  if &termencoding == ""
    let &termencoding = &encoding
  endif
  set encoding=utf-8
  setglobal fileencoding=utf-8
  set fileencodings=ucs-bom,utf-8,latin1
endif

" Sends swap files to /tmp or /var/tmp, and make the swp file names unique by
" dir
set directory=/tmp//,/var/tmp//

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

""""""""""""""""""""""
" Mapleader bindings "
""""""""""""""""""""""
" Rebind <leader> to ","
let mapleader = ","

" Clears highlighting after a search
nnoremap <leader><space> :noh<cr>

" Toggle highlighting of the last search.
noremap <Leader>h :set hlsearch! hlsearch?<CR>

" Toggle between relative and not
noremap <Leader>r :set relativenumber! relativenumber?<CR>

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

" Open a scratch buffer.
noremap <Leader>s :Scratch<CR>

" strip all trailing whitespace in current file
"fun! StripTrailingWhitespaces()
"   let l = line(".")
"   let c = col(".")
"   %s/\s\+$//e
"   call cursor(l, c)
"endfun
"autocmd FileType * autocmd BufWritePre <buffer> :call StripTrailingWhitespaces()
"
"nnoremap <leader>W :call StripTrailingWhitespaces()<CR>

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
set remap

map <up> <Nop>
map <down> <Nop>
map <left> <Nop>
map <right> <Nop>

" Make j and k react better on wrapped lines
noremap j gj
noremap k gk

" Make Y behave like other capitals - copy from cursor to EOL, not whole line
nnoremap Y y$

" Using a mouse, like a boss (including scrolling)
set mouse=a

" Read .love files like a browser? Heck yes
au BufReadCmd *.love call zip#Browse(expand("<amatch>"))

" LESS files!
au BufNewFile,BufRead *.less set filetype=less

" Read local-machine-only settings
let localrc = $HOME . '/.vimrclocal'

if filereadable(localrc)
    exe "source" localrc
endif

" The color of things
colorscheme inkpot
" colorscheme solarized
" highlight Normal ctermfg=white ctermbg=black


" Change behavior of *,g* so * searches for the word under the cursor anywhere
" instead of just as a whle word. Also, strip trailing dash from word so a
" search with cursor on $blah->blah() still finds $blah (and the reverse)
noremap * :call SearchCurrentWord()<CR>

function! SearchCurrentWord()
   " Strip dash from end of word
   let cur_word = substitute(expand("<cword>"), '-$','','')
   let @/ = cur_word
   set hlsearch
   normal n
endfunction

let g:go_fmt_command = "goimports"
