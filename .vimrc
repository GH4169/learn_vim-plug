set clipboard=unnamedplus
set number relativenumber

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

let mapleader=" "
nnoremap <leader>n :NERDTreeToggle<cr>
nnoremap <F2> :tabnew ~/.vimrc<cr>
nnoremap <tab> :tabnext<cr>

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


cnoremap ( ()<left>
cnoremap [ []<left>
cnoremap { {}<left>

set foldmethod=marker
nnoremap zo za
cnoremap qc tabclose

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif


call plug#begin()
" List your plugins here
Plug 'tpope/vim-sensible'
Plug 'preservim/nerdtree'
Plug 'vhda/verilog_systemverilog.vim'

call plug#end()
autocmd vimEnter * NERDTree | wincmd p


call pmana#begin()
"Pmana 'test/zhou', {'frozen': 1}
Pmana 'test/zhou'
" List your plugins here
call pmana#end()

"call pman#begin()
""Pmana 'test/zhou', {'frozen': 1}
"Pman 'test/zhou'
"" List your plugins here
"call pman#end()


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
endfunction
