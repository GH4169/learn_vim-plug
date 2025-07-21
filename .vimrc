
" Basic Settings{{{

let mapleader=" "

if has('gui_running')
  " colorscheme desert
  set guifont=courier\ 10\ pitch\ 18
  set lines=80 columns=160
endif


set clipboard=unnamedplus
"set number relativenumber
set number

set expandtab          " set forbidden space to replace tab
set tabstop=2            " number of spaces used by tabs when editing
set shiftwidth=2         " number of spaces tab occupies when formatting
set softtabstop=2        " set 4 spaces as tabs
set smarttab             " use tabs at the beginning of lines and segments

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" search config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set hlsearch            " highlight search results
set incsearch           " turn on real-time search
"set ignorecase          " search is not case sensitive
set smartcase           " search smart match case

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set cursorline
set foldmethod=marker

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

set t_RV=
set t_TE=
set t_TI=
autocmd VimEnter * redraw!
" 插入模式竖线光标（这里用 6 代表竖线，5 也是竖线，可根据终端调整）
let &t_SI = "\e[6 q"
" 普通模式方块光标
let &t_EI = "\e[2 q"
"set spell

"}}}

" Plug{{{
call plug#begin()
" List your plugins here
Plug 'tpope/vim-sensible'
Plug 'preservim/nerdtree'
Plug 'vhda/verilog_systemverilog.vim'
Plug 'luochen1990/rainbow'
Plug 'Yggdroot/indentLine'
Plug 'HonkW93/automatic-verilog'
Plug 'tpope/vim-commentary'
Plug 'RRethy/vim-illuminate'
" Plug 'tpope/vim-surround'
Plug 'gcmt/wildfire.vim'
Plug 'junegunn/vim-easy-align'
Plug 'morhetz/gruvbox'
Plug 'ghifarit53/tokyonight-vim'
Plug 'sheerun/vim-polyglot'
Plug 'kshenoy/vim-signature'
call plug#end()

"call pmana#begin(){{{
""Pmana 'test/zhou', {'frozen': 1}
"Pmana 'test/zhou'
"" List your plugins here
"call pmana#end()

"call pman#begin()
""Pmana 'test/zhou', {'frozen': 1}
"Pman 'test/zhou'
"" List your plugins here
"call pman#end()}}}
"}}}

"Plug config{{{
autocmd vimEnter * NERDTree | wincmd p

let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle

"  \       'after': [
"  \         'syn clear verilogStatement',
"  \       ],
let g:rainbow_conf = {
  \   'guifgs': ['DarkYellow', 'darkorange3', 'seagreen3', 'firebrick'],
  \   'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
  \   'guis': [''],
  \   'cterms': [''],
  \   'operators': '_,_',
  \   'separately': {
  \     '*': {},
  \     'verilog_systemverilog': {
  \       'parentheses': ['start=/\<begin\>/ end=/\<end\>/ fold','start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
  \       'after': [
  \         'syn clear verilogStatement',
  \       ],
  \     },
  \     'markdown': {
  \       'parentheses_options': 'containedin=markdownCode contained',
  \     },
  \     'lisp': {
  \       'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
  \     },
  \     'haskell': {
  \       'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/\v\{\ze[^-]/ end=/}/ fold'],
  \     },
  \     'vim': {
  \       'parentheses_options': 'containedin=vimFuncBody',
  \     },
  \     'perl': {
  \       'syn_name_prefix': 'perlBlockFoldRainbow',
  \     },
  \     'stylus': {
  \       'parentheses': ['start=/{/ end=/}/ fold contains=@colorableGroup'],
  \     },
  \     'css': 0,
  \     'nerdtree': 0,
  \   }
  \}

autocmd FileType verilog_systemverilog setlocal commentstring=//\ %s


augroup illuminate_augroup
    autocmd!
    autocmd VimEnter * hi illuminatedWord cterm=underline gui=underline
augroup END

" let g:wildfire_objects = ["iw","i'", 'i"', "i)", "i]", "i}","a'", 'a"', "a)", "a]", "a}"]
let g:wildfire_objects = ["i'", 'i"', "i)", "i]", "i}","a'", 'a"', "a)", "a]", "a}","iw"]

" Start interactive EasyAlign in visual mode (e.g. vipga)
xnoremap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nnoremap ga <Plug>(EasyAlign)

set termguicolors
" For tokyonight colorscheme
" let g:tokyonight_style = 'night' " available: night, storm
" let g:tokyonight_enable_italic = 1
" let g:tokyonight_terminal_colors = 1
" colorscheme tokyonight

" For gruvbox colorscheme
autocmd vimenter * ++nested colorscheme gruvbox
set bg=dark

" let g:indentLine_char_list = ['|', '¦', '┆', '┊']
let g:indentLine_char_list = ['¦', '┊', '┆', '|']

let g:SignaturePersistMarks = 0
let g:SignatureMap = {
  \ 'Leader'             :  "m",
  \ 'PlaceNextMark'      :  "m,",
  \ 'ToggleMarkAtLine'   :  "m.",
  \ 'PurgeMarksAtLine'   :  "m-",
  \ 'DeleteMark'         :  "dm",
  \ 'PurgeMarks'         :  "m<Space>",
  \ 'PurgeMarkers'       :  "m<BS>",
  \ 'GotoNextLineAlpha'  :  "nm",
  \ 'GotoPrevLineAlpha'  :  "pm",
  \ 'GotoNextSpotAlpha'  :  "`]",
  \ 'GotoPrevSpotAlpha'  :  "`[",
  \ 'GotoNextLineByPos'  :  "]'",
  \ 'GotoPrevLineByPos'  :  "['",
  \ 'GotoNextSpotByPos'  :  "]`",
  \ 'GotoPrevSpotByPos'  :  "[`",
  \ 'GotoNextMarker'     :  "]-",
  \ 'GotoPrevMarker'     :  "[-",
  \ 'GotoNextMarkerAny'  :  "]=",
  \ 'GotoPrevMarkerAny'  :  "[=",
  \ 'ListBufferMarks'    :  "m/",
  \ 'ListBufferMarkers'  :  "m?"
  \ }
"}}}

" map{{{
nnoremap <leader>n :NERDTreeToggle<cr>
nnoremap <F2> :tabnew ~/.vimrc<cr>
nnoremap <F3> :tabnew ~/.bashrc<cr>
nnoremap <tab> :tabnext<cr>
nnoremap <c-n> :tabnew 

" change window width
nnoremap <c-up> <c-w>+
nnoremap <c-down> <c-w>-
nnoremap <c-left> <c-w><
nnoremap <c-right> <c-w>>

" change window pos in normal
nnoremap <c-k> <c-w>k
nnoremap <c-j> <c-w>j
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
nnoremap <s-up>    <c-w>k
nnoremap <s-down>  <c-w>j
nnoremap <s-left>  <c-w>h
nnoremap <s-right> <c-w>l

" insert model to move cursor
inoremap <c-j> <down>
inoremap <c-k> <up>
inoremap <c-l> <right>
inoremap <c-h> <left>

nnoremap <leader>so :source $MYVIMRC<cr>
nnoremap ws <c-w>s
nnoremap vs <c-v>s

inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap " ""<left>
inoremap ' ''<left>
autocmd FileType verilog_systemverilog inoremap <buffer> ' '

cnoremap ( ()<left>
cnoremap [ []<left>
cnoremap { {}<left>
cnoremap " ""<left>
cnoremap ' ''<left>

nnoremap zo za
cnoremap qc tabclose

" nnoremap <CR> viw
" vnoremap <CR> <ESC>

"Toggle Menu and Toolbar
set guioptions-=m
set guioptions-=T
nnoremap <silent> <leader>gui :if &guioptions=~#'T' <Bar>
        \set guioptions-=T <Bar>
        \set guioptions-=m <bar>
    \else <Bar>
        \set guioptions+=T <Bar>
        \set guioptions+=m <Bar>
    \endif<CR>


nnoremap <leader>I i/*autoinst*/<ESC>:call AutoInst(0)<CR>
nnoremap <leader>P i/*autoinstparam*/<ESC>:call AutoPara(0)<CR>

nnoremap cm <Plug>CommentaryLine
nnoremap cu <Plug>CommentaryLine
vnoremap cm <Plug>Commentary
vnoremap cu <Plug>Commentary


inoremap <expr> <Tab> match(strpart(getline('.'), 0, col('.') - 1), '^\s*$') == 0 ? "\<Tab>" : "\<C-n>"
"}}}



" For test{{{
function! Vimrc_print(string, ...)
  echom "string = " . a:string
  echom a:0
  if a:0 > 1
    return s:err('Invalid number of arguments (1..2)')
  endif
endfunction

command! -nargs=+ -bar Vstr call Vimrc_print(<args>)
""Vstr 'asdf'


function! s:err(msg)
  echohl ErrorMsg
  echom '[vim-plug] '.a:msg
  echohl None
endfunction

function! s:is_local_pmana(repo)
  echo a:repo[0] =~ '[/$~]'
  return a:repo[0] =~ '[/$~]'
endfunction

function! Infer_properties(name, repo)
  let repo = a:repo
  if s:is_local_pmana(repo)
    return { 'dir': s:dirpath(s:pmana_expand(repo)) }
  else
    if repo =~ ':'
      let uri = repo
    else
      if repo !~ '/'
        throw printf('Invalid argument: %s (implicit `vim-scripts'' expansion is deprecated)', repo)
      endif
      let fmt = get(g:, 'pmana_url_format', 'https://git::@github.com/%s.git')
      let uri = printf(fmt, repo)
      echom uri
    endif

    echom { 'dir': s:dirpath(g:pmana_home.'/'.a:name), 'uri': uri }
    return { 'dir': s:dirpath(g:pmana_home.'/'.a:name), 'uri': uri }
  endif
endfunction

function! s:dirpath(path)
  return substitute(a:path, '[/\\]*$', '/', '')
endfunction



function! s:escrtp(path)
  return escape(a:path, ' ,')
endfunction

function! s:split_rtp()
  return split(&rtp, '\\\@<!,')
endfunction


let s:first_rtp = s:escrtp(get(s:split_rtp(), 0, ''))
let s:last_rtp  = s:escrtp(get(s:split_rtp(), -1, ''))

    execute 'set rtp^='.s:first_rtp
    execute 'set rtp+='.s:last_rtp
function! s:reorg_rtp()
  if !empty(s:first_rtp)
    execute 'set rtp-='.s:first_rtp
    execute 'set rtp-='.s:last_rtp
  endif

  if !empty(s:first_rtp)
    execute 'set rtp^='.s:first_rtp
    execute 'set rtp+='.s:last_rtp
  endif
endfunction"}}}

