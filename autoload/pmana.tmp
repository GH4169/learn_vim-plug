
function! pmana#print()
  echom "me "      . s:me
  echom s:loaded
  echom s:is_powershell(&shell)
"  echom pmana_home
  echom "end"
endfunction

"{{{
let s:cpo_save = &cpo
set cpo&vim

let s:pmana_src = 'https://github.com/junegunn/vim-pmana.git'
let s:pmana_tab = get(s:, 'pmana_tab', -1)
let s:pmana_buf = get(s:, 'pmana_buf', -1)

let s:mac_gui = has('gui_macvim') && has('gui_running')
let s:is_win = has('win32')
let s:nvim = has('nvim-0.2') || (has('nvim') && exists('*jobwait') && !s:is_win)
let s:vim8 = has('patch-8.0.0039') && exists('*job_start')

if s:is_win && &shellslash
  set noshellslash
  let s:me = resolve(expand('<sfile>:p'))
  set shellslash
else
  let s:me = resolve(expand('<sfile>:p'))
endif

let s:base_spec = { 'branch': '', 'frozen': 0 }

let s:TYPE = {
\   'string':  type(''),
\   'list':    type([]),
\   'dict':    type({}),
\   'funcref': type(function('call'))
\ }
let s:loaded = get(s:, 'loaded', {})
let s:triggers = get(s:, 'triggers', {})
"}}}

"{{{
" function{{{
function! s:is_powershell(shell)
  return a:shell =~# 'powershell\(\.exe\)\?$' || a:shell =~# 'pwsh\(\.exe\)\?$'
endfunction

function! s:isabsolute(dir) abort
  return a:dir =~# '^/' || (has('win32') && a:dir =~? '^\%(\\\|[A-Z]:\)')
endfunction

function! s:git_dir(dir) abort
  let gitdir = s:trim(a:dir) . '/.git'
  if isdirectory(gitdir)
    return gitdir
  endif
  if !filereadable(gitdir)
    return ''
  endif
  let gitdir = matchstr(get(readfile(gitdir), 0, ''), '^gitdir: \zs.*')
  if len(gitdir) && !s:isabsolute(gitdir)
    let gitdir = a:dir . '/' . gitdir
  endif
  return isdirectory(gitdir) ? gitdir : ''
endfunction

function! s:git_origin_url(dir) abort
  let gitdir = s:git_dir(a:dir)
  let config = gitdir . '/config'
  if empty(gitdir) || !filereadable(config)
    return ''
  endif
  return matchstr(join(readfile(config)), '\[remote "origin"\].\{-}url\s*=\s*\zs\S*\ze')
endfunction

function! s:git_revision(dir) abort
  let gitdir = s:git_dir(a:dir)
  let head = gitdir . '/HEAD'
  if empty(gitdir) || !filereadable(head)
    return ''
  endif

  let line = get(readfile(head), 0, '')
  let ref = matchstr(line, '^ref: \zs.*')
  if empty(ref)
    return line
  endif

  if filereadable(gitdir . '/' . ref)
    return get(readfile(gitdir . '/' . ref), 0, '')
  endif

  if filereadable(gitdir . '/packed-refs')
    for line in readfile(gitdir . '/packed-refs')
      if line =~# ' ' . ref
        return matchstr(line, '^[0-9a-f]*')
      endif
    endfor
  endif

  return ''
endfunction

function! s:git_local_branch(dir) abort
  let gitdir = s:git_dir(a:dir)
  let head = gitdir . '/HEAD'
  if empty(gitdir) || !filereadable(head)
    return ''
  endif
  let branch = matchstr(get(readfile(head), 0, ''), '^ref: refs/heads/\zs.*')
  return len(branch) ? branch : 'HEAD'
endfunction

function! s:git_origin_branch(spec)
  if len(a:spec.branch)
    return a:spec.branch
  endif

  " The file may not be present if this is a local repository
  let gitdir = s:git_dir(a:spec.dir)
  let origin_head = gitdir.'/refs/remotes/origin/HEAD'
  if len(gitdir) && filereadable(origin_head)
    return matchstr(get(readfile(origin_head), 0, ''),
                  \ '^ref: refs/remotes/origin/\zs.*')
  endif

  " The command may not return the name of a branch in detached HEAD state
  let result = s:lines(s:system('git symbolic-ref --short HEAD', a:spec.dir))
  return v:shell_error ? '' : result[-1]
endfunction
"}}}

if s:is_win
"  function! s:pmana_call(fn, ...){{{
"    let shellslash = &shellslash
"    try
"      set noshellslash
"      return call(a:fn, a:000)
"    finally
"      let &shellslash = shellslash
"    endtry
"  endfunction}}}
else
  function! s:pmana_call(fn, ...)
    return call(a:fn, a:000)
  endfunction
endif

" function{{{
function! s:pmana_getcwd()
  return s:pmana_call('getcwd')
endfunction

function! s:pmana_fnamemodify(fname, mods)
  return s:pmana_call('fnamemodify', a:fname, a:mods)
endfunction

function! s:pmana_expand(fmt)
  return s:pmana_call('expand', a:fmt, 1)
endfunction

function! s:pmana_tempname()
  return s:pmana_call('tempname')
endfunction
"}}}
"}}}

"function! pmana#begin(...){{{
function! pmana#begin(...)
"  echom "enter pmana#begin function"
  if a:0 > 0
    let pmana_home = s:path(s:pmana_fnamemodify(s:pmana_expand(a:1), ':p'))
  elseif exists('g:pmana_home')
    let pmana_home = s:path(g:pmana_home)
"    echom g:pmana_home
  elseif has('nvim')
    let pmana_home = stdpath('data') . '/pmanaged'
  elseif !empty(&rtp)
    let pmana_home = s:path(split(&rtp, ',')[0]) . '/pmanaged'
"    echom "pmana_home = " . pmana_home
  else
    return s:err('Unable to determine pmana home. Try calling pmana#begin() with a path argument.')
  endif

"  echom s:pmana_fnamemodify(pmana_home, ':t') 

  if s:pmana_fnamemodify(pmana_home, ':t') ==# 'pmanain' && s:pmana_fnamemodify(pmana_home, ':h') ==# s:first_rtp
    return s:err('Invalid pmana home. '.pmana_home.' is a standard Vim runtime path and is not allowed.')
  endif

  let g:pmana_home = pmana_home
  let g:pmanas = {}
  let g:pmanas_order = []
  let s:triggers = {}

  call s:define_commands()
  return 1
endfunction
"}}}

function! s:define_commands()
  command! -nargs=+ -bar Pmana call pmana#(<args>)

"{{{
"  echom "git " . executable('git')

  if !executable('git')
    return s:err('`git` executable not found. Most commands will not be available. To suppress this message, prepend `silent!` to `call pmana#begin(...)`.')
  endif

"  echom "win32 " . has('win32')

  if has('win32')
  \ && &shellslash
  \ && (&shell =~# 'cmd\(\.exe\)\?$' || s:is_powershell(&shell))
    return s:err('vim-pmana does not support shell, ' . &shell . ', when shellslash is set.')
  endif

"  echom "multi1: " 
"  echom !has('nvim') && (has('win32') || has('win32unix')) && !has('multi_byte')


  if !has('nvim')
    \ && (has('win32') || has('win32unix'))
    \ && !has('multi_byte')

"    echom "multi1: " 
    return s:err('Vim needs +multi_byte feature on Windows to run shell commands. Enable +iconv for best results.')
  endif
"}}}

  command! -nargs=* -bar -bang -complete=customlist,s:names PmanaInstall call s:install(<bang>0, [<f-args>])
  command! -nargs=* -bar -bang -complete=customlist,s:names PmanaUpdate  call s:update(<bang>0, [<f-args>])
  command! -nargs=0 -bar -bang PmanaClean call s:clean(<bang>0)
  command! -nargs=0 -bar PmanaUpgrade if s:upgrade() | execute 'source' s:esc(s:me) | endif
  command! -nargs=0 -bar PmanaStatus  call s:status()
  command! -nargs=0 -bar PmanaDiff    call s:diff()
  command! -nargs=? -bar -bang -complete=file PmanaSnapshot call s:snapshot(<bang>0, <f-args>)
endfunction


"{{{
if s:is_win
"  function! s:path(path){{{
"    return s:trim(substitute(a:path, '/', '\', 'g'))
"  endfunction
"
"  function! s:dirpath(path)
"    return s:path(a:path) . '\'
"  endfunction
"
"  function! s:is_local_pmana(repo)
"    return a:repo =~? '^[a-z]:\|^[%~]'
"  endfunction
"
"  " Copied from fzf
"  function! s:wrap_cmds(cmds)
"    let cmds = [
"      \ '@echo off',
"      \ 'setlocal enabledelayedexpansion']
"    \ + (type(a:cmds) == type([]) ? a:cmds : [a:cmds])
"    \ + ['endlocal']
"    if has('iconv')
"      if !exists('s:codepage')
"        let s:codepage = libcallnr('kernel32.dll', 'GetACP', 0)
"      endif
"      return map(cmds, printf('iconv(v:val."\r", "%s", "cp%d")', &encoding, s:codepage))
"    endif
"    return map(cmds, 'v:val."\r"')
"  endfunction
"
"  function! s:batchfile(cmd)
"    let batchfile = s:pmana_tempname().'.bat'
"    call writefile(s:wrap_cmds(a:cmd), batchfile)
"    let cmd = pmana#shellescape(batchfile, {'shell': &shell, 'script': 0})
"    if s:is_powershell(&shell)
"      let cmd = '& ' . cmd
"    endif
"    return [batchfile, cmd]
"  endfunction}}}
else
  function! s:path(path)
    return s:trim(a:path)
  endfunction

  function! s:dirpath(path)
    return substitute(a:path, '[/\\]*$', '/', '')
  endfunction

  function! s:is_local_pmana(repo)
    return a:repo[0] =~ '[/$~]'
  endfunction
endif
"}}}

function! s:trim(str)
  return substitute(a:str, '[\/]\+$', '', '')
endfunction

"{{{
function! s:err(msg)
  echohl ErrorMsg
  echom '[vim-pmana] '.a:msg
  echohl None
endfunction
"}}}

" pmana#(repo, ...){{{
function! pmana#(repo, ...)
  if a:0 > 1
    return s:err('Invalid number of arguments (1..2)')
  endif

"  try{{{
"    let repo = s:trim(a:repo)
"    let opts = a:0 == 1 ? s:parse_options(a:1) : s:base_spec
"    let name = get(opts, 'as', s:pmana_fnamemodify(repo, ':t:s?\.git$??'))
"    let spec = extend(s:infer_properties(name, repo), opts)
"    if !has_key(g:pmanas, name)
"      call add(g:pmanas_order, name)
"    endif
"    let g:pmanas[name] = spec
"    let s:loaded[name] = get(s:loaded, name, 0)
"  catch
"    return s:err(repo . ' ' . v:exception)
"  endtry}}}

  try
    let repo = s:trim(a:repo)
    let opts = a:0 == 1 ? s:parse_options(a:1) : s:base_spec
    let name = get(opts, 'as', s:pmana_fnamemodify(repo, ':t:s;\.git$;;'))

    let spec = extend(s:infer_properties(name, repo), opts)
    if !has_key(g:pmanas, name)
      call add(g:pmanas_order, name)
    endif
    let g:pmanas[name] = spec

"    echom "start in pmana#()"
"    echom get(s:loaded, name, 0)
"    echom "end in pmana#()"

    let s:loaded[name] = get(s:loaded, name, 0)
"    echom s:loaded[name]
  catch
    "return s:err(a:repo . ' ' . 'test')
    return s:err(repo . ' ' . v:exception)
  endtry
endfunction"}}}


"function! s:infer_properties(name, repo)"{{{
function! s:infer_properties(name, repo)
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
   "  echom uri
    endif
   " echom { 'dir': s:dirpath(g:pmana_home.'/'.a:name), 'uri': uri }
    return { 'dir': s:dirpath(g:pmana_home.'/'.a:name), 'uri': uri }
  endif
endfunction
"}}}



function! s:install(force, names)
  "echom a:force
  "echom a:names
  call s:update_impl(0, a:force, a:names)
endfunction

function! s:update(force, names)
  call s:update_impl(1, a:force, a:names)
endfunction

function! s:is_managed(name)
  return has_key(g:pmanas[a:name], 'uri')
endfunction

function! s:warn(cmd, msg)
  echohl WarningMsg
  execute a:cmd 'a:msg'
  echohl None
endfunction

function! s:chsh(swap)
  let prev = [&shell, &shellcmdflag, &shellredir]
  if !s:is_win
    set shell=sh
  endif
  if a:swap
    if s:is_powershell(&shell)
      let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s'
    elseif &shell =~# 'sh' || &shell =~# 'cmd\(\.exe\)\?$'
      set shellredir=>%s\ 2>&1
    endif
  endif
  return prev
endfunction

function! pmana#shellescape(arg, ...)
  if a:arg =~# '^[A-Za-z0-9_/:.-]\+$'
    return a:arg
  endif
  let opts = a:0 > 0 && type(a:1) == s:TYPE.dict ? a:1 : {}
  let shell = get(opts, 'shell', s:is_win ? 'cmd.exe' : 'sh')
  let script = get(opts, 'script', 1)
  if shell =~# 'cmd\(\.exe\)\?$'
    return s:shellesc_cmd(a:arg, script)
  elseif s:is_powershell(shell)
    return s:shellesc_ps1(a:arg)
  endif
  return s:shellesc_sh(a:arg)
endfunction

function! s:system(cmd, ...)
  let batchfile = ''
  try
    let [sh, shellcmdflag, shrd] = s:chsh(1)
    "echom sh
    "echom shellcmdflag
    "echom shrd
    if type(a:cmd) == s:TYPE.list
      " Neovim's system() supports list argument to bypass the shell
      " but it cannot set the working directory for the command.
      " Assume that the command does not rely on the shell.
      if has('nvim') && a:0 == 0
        return system(a:cmd)
      endif
      let cmd = join(map(copy(a:cmd), 'pmana#shellescape(v:val, {"shell": &shell, "script": 0})'))
      if s:is_powershell(&shell)
        let cmd = '& ' . cmd
      endif
    else
      let cmd = a:cmd
    endif
    if a:0 > 0
      let cmd = s:with_cd(cmd, a:1, type(a:cmd) != s:TYPE.list)
    endif
    if s:is_win && type(a:cmd) != s:TYPE.list
      let [batchfile, cmd] = s:batchfile(cmd)
    endif
    "echom cmd
    "echom system("git --version")
    return system(cmd)
  finally
    let [&shell, &shellcmdflag, &shellredir] = [sh, shellcmdflag, shrd]
    if s:is_win && filereadable(batchfile)
      call delete(batchfile)
    endif
  endtry
endfunction

function! s:version_requirement(val, min)
  for idx in range(0, len(a:min) - 1)
    let v = get(a:val, idx, 0)
    if     v < a:min[idx] | return 0
    elseif v > a:min[idx] | return 1
    endif
  endfor
  return 1
endfunction

function! s:git_version_requirement(...)
  if !exists('s:git_version')
    let s:git_version = map(split(split(s:system(['git', '--version']))[2], '\.'), 'str2nr(v:val)')
  endif
  return s:version_requirement(s:git_version, a:000)
endfunction

function! s:job_abort(cancel)
  if (!s:nvim && !s:vim8) || !exists('s:jobs')
    return
  endif

  echom s:jobs
  echom "after 1"
  for [name, j] in items(s:jobs)
    if s:nvim
      silent! call jobstop(j.jobid)
    elseif s:vim8
      silent! call job_stop(j.jobid)
    endif
    if j.new
      call s:rm_rf(g:pmanas[name].dir)
    endif
    if a:cancel
      call s:mark_aborted(name, 'Aborted')
    endif
  endfor

  if a:cancel
    for todo in values(s:update.todo)
      let todo.abort = 1
    endfor
  else
    let s:jobs = {}
  endif
  echom s:jobs
  echom "after 2"
endfunction

function! s:pmana_window_exists()
  let buflist = tabpagebuflist(s:pmana_tab)
  return !empty(buflist) && index(buflist, s:pmana_buf) >= 0
endfunction

function! s:switch_in()
  if !s:pmana_window_exists()
    echom "in if of s:pmana_window_exists()"
    return 0
  endif

  if winbufnr(0) != s:pmana_buf
    let s:pos = [tabpagenr(), winnr(), winsaveview()]
    execute 'normal!' s:pmana_tab.'gt'
    let winnr = bufwinnr(s:pmana_buf)
    execute winnr.'wincmd w'
    call add(s:pos, winsaveview())
  else
    let s:pos = [winsaveview()]
  endif

  setlocal modifiable
  return 1
endfunction

function! s:new_window()
  execute get(g:, 'pmana_window', '-tabnew')
endfunction

function! s:close_pane()
  echom "in close_pane()"
  echom exists('s:jobs') 
  if b:pmana_preview == 1
    echom "1"
    pc
    let b:pmana_preview = -1
  elseif exists('s:jobs') && !empty(s:jobs)
    echom "2"
    call s:job_abort(1)
  else
    echom "3"
    bd
  endif
endfunction

function! s:finish_bindings()
  nnoremap <silent> <buffer> R  :call <SID>retry()<cr>
  nnoremap <silent> <buffer> D  :PmanaDiff<cr>
  nnoremap <silent> <buffer> S  :PmanaStatus<cr>
  nnoremap <silent> <buffer> U  :call <SID>status_update()<cr>
  xnoremap <silent> <buffer> U  :call <SID>status_update()<cr>
  nnoremap <silent> <buffer> ]] :silent! call <SID>section('')<cr>
  nnoremap <silent> <buffer> [[ :silent! call <SID>section('b')<cr>
endfunction

function! s:assign_name()
  " Assign buffer name
  let prefix = '[Pmanans]'
  let name   = prefix
  let idx    = 2
  while bufexists(name)
    let name = printf('%s (%s)', prefix, idx)
    let idx = idx + 1
  endwhile
  silent! execute 'f' fnameescape(name)
endfunction

"function! s:syntax(){{{
function! s:syntax()
  syntax clear
  syntax region pmana1 start=/\%1l/ end=/\%2l/ contains=pmanaNumber
  syntax region pmana2 start=/\%2l/ end=/\%3l/ contains=pmanaBracket,pmanaX,pmanaAbort
  syn match pmanaNumber /[0-9]\+[0-9.]*/ contained
  syn match pmanaBracket /[[\]]/ contained
  syn match pmanaX /x/ contained
  syn match pmanaAbort /\~/ contained
  syn match pmanaPlus /^+/
  syn match pmanaStar /^*/
  syn match pmanaMessage /\(^- \)\@<=.*/
  syn match pmanaName /\(^- \)\@<=[^ ]*:/
  syn match pmanaSha /\%(: \)\@<=[0-9a-f]\{4,}$/
  syn match pmanaTag /(tag: [^)]\+)/
  syn match pmanaInstall /\(^+ \)\@<=[^:]*/
  syn match pmanaUpdate /\(^* \)\@<=[^:]*/
  syn match pmanaCommit /^  \X*[0-9a-f]\{7,9} .*/ contains=pmanaRelDate,pmanaEdge,pmanaTag
  syn match pmanaEdge /^  \X\+$/
  syn match pmanaEdge /^  \X*/ contained nextgroup=pmanaSha
  syn match pmanaSha /[0-9a-f]\{7,9}/ contained
  syn match pmanaRelDate /([^)]*)$/ contained
  syn match pmanaNotLoaded /(not loaded)$/
  syn match pmanaError /^x.*/
  syn region pmanaDeleted start=/^\~ .*/ end=/^\ze\S/
  syn match pmanaH2 /^.*:\n-\+$/
  syn match pmanaH2 /^-\{2,}/
  syn keyword Function PmanaInstall PmanaStatus PmanaUpdate PmanaClean
  hi def link pmana1       Title
  hi def link pmana2       Repeat
  hi def link pmanaH2      Type
  hi def link pmanaX       Exception
  hi def link pmanaAbort   Ignore
  hi def link pmanaBracket Structure
  hi def link pmanaNumber  Number

  hi def link pmanaDash    Special
  hi def link pmanaPlus    Constant
  hi def link pmanaStar    Boolean

  hi def link pmanaMessage Function
  hi def link pmanaName    Label
  hi def link pmanaInstall Function
  hi def link pmanaUpdate  Type

  hi def link pmanaError   Error
  hi def link pmanaDeleted Ignore
  hi def link pmanaRelDate Comment
  hi def link pmanaEdge    PreProc
  hi def link pmanaSha     Identifier
  hi def link pmanaTag     Constant

  hi def link pmanaNotLoaded Comment
endfunction
"}}}

function! s:prepare(...)
  if empty(s:pmana_getcwd())
    throw 'Invalid current working directory. Cannot proceed.'
  endif

  for evar in ['$GIT_DIR', '$GIT_WORK_TREE']
    if exists(evar)
      throw evar.' detected. Cannot proceed.'
    endif
  endfor

  call s:job_abort(0)

  if s:switch_in()
    if b:pmana_preview == 1
      pc
    endif
    enew
  else
    call s:new_window()
  endif

  nnoremap <silent> <buffer> q :call <SID>close_pane()<cr>
  echom a:0
  if a:0 == 0
    call s:finish_bindings()
  endif
  let b:pmana_preview = -1
  let s:pmana_tab = tabpagenr()
  let s:pmana_buf = winbufnr(0)
  call s:assign_name()

  for k in ['<cr>', 'L', 'o', 'X', 'd', 'dd']
    execute 'silent! unmap <buffer>' k
  endfor
  setlocal buftype=nofile bufhidden=wipe nobuflisted nolist noswapfile nowrap cursorline modifiable nospell
  if exists('+colorcolumn')
    setlocal colorcolumn=
  endif
  setf vim-pmana
  if exists('g:syntax_on')
    call s:syntax()
  endif
endfunction

function! s:lpad(str, len)
  return a:str . repeat(' ', a:len - len(a:str))
endfunction

function! s:progress_bar(line, bar, total)
  call setline(a:line, '[' . s:lpad(a:bar, a:total) . ']')
endfunction

function! s:switch_out(...)
  call winrestview(s:pos[-1])
  setlocal nomodifiable
  if a:0 > 0
    execute a:1
  endif

  if len(s:pos) > 1
    execute 'normal!' s:pos[0].'gt'
    execute s:pos[1] 'wincmd w'
    call winrestview(s:pos[2])
  endif
endfunction

function! s:bar()
  echom "s:switch_in():"
  echom s:switch_in()
  if s:switch_in()
    echom s:update
    let total = len(s:update.all)
    call setline(1, (s:update.pull ? 'Updating' : 'Installing').
          \ ' plugins ('.len(s:update.bar).'/'.total.')')
    call s:progress_bar(2, s:update.bar, total)
    call s:switch_out()
  endif
endfunction

function! s:progress_opt(base)
  return a:base && !s:is_win &&
        \ s:git_version_requirement(1, 7, 1) ? '--progress' : ''
endfunction

function! s:mark_aborted(name, message)
  let attrs = { 'running': 0, 'error': 1, 'abort': 1, 'lines': [a:message] }
  let s:jobs[a:name] = extend(get(s:jobs, a:name, {}), attrs)
endfunction

function! s:log(bullet, name, lines)
  if s:switch_in()
    let [b, e] = s:logpos(a:name)
    if b > 0
      silent execute printf('%d,%d d _', b, e)
      if b > winheight('.')
        let b = 4
      endif
    else
      let b = 4
    endif
    " FIXME For some reason, nomodifiable is set after :d in vim8
    setlocal modifiable
    call append(b - 1, s:format_message(a:bullet, a:name, a:lines))
    call s:switch_out()
  endif
endfunction

function! s:reap(name)
  let job = remove(s:jobs, a:name)
  if job.error
    call add(s:update.errors, a:name)
  elseif get(job, 'new', 0)
    let s:update.new[a:name] = 1
  endif

  let more = len(get(job, 'queue', []))
  let result = job.error ? join(job.lines, "\n") : s:last_non_empty_line(job.lines)
  if len(result)
    call s:log(s:bullet_for(job), a:name, result)
  endif

  if !job.error && more
    let job.spec.queue = job.queue
    let s:update.todo[a:name] = job.spec
  else
    let s:update.bar .= s:bullet_for(job, '=')
    call s:bar()
  endif
endfunction

"function! s:tick() {{{
function! s:tick()
  let pull = s:update.pull
  let prog = s:progress_opt(s:nvim || s:vim8)
while 1 " Without TCO, Vim stack is bound to explode
  if empty(s:update.todo)
    if empty(s:jobs) && !s:update.fin
      call s:update_finish()
      let s:update.fin = 1
    endif
    return
  endif

  let name = keys(s:update.todo)[0]
  let spec = remove(s:update.todo, name)
  if get(spec, 'abort', 0)
    call s:mark_aborted(name, 'Skipped')
    call s:reap(name)
    continue
  endif

  let queue = get(spec, 'queue', [])
  let new = empty(globpath(spec.dir, '.git', 1))

  if empty(queue)
    call s:log(new ? '+' : '*', name, pull ? 'Updating ...' : 'Installing ...')
    redraw
  endif

  let has_tag = has_key(spec, 'tag')
  if len(queue)
    call s:spawn(name, spec, queue, { 'dir': spec.dir })
  elseif !new
    let [error, _] = s:git_validate(spec, 0)
    if empty(error)
      if pull
        let cmd = s:git_version_requirement(2) ? ['git', '-c', 'credential.helper=', 'fetch'] : ['git', 'fetch']
        if has_tag && !empty(globpath(spec.dir, '.git/shallow'))
          call extend(cmd, ['--depth', '99999999'])
        endif
        if !empty(prog)
          call add(cmd, prog)
        endif
        let queue = [cmd, split('git remote set-head origin -a')]
        if !has_tag && !has_key(spec, 'commit')
          call extend(queue, [function('s:checkout_command'), function('s:merge_command')])
        endif
        call s:spawn(name, spec, queue, { 'dir': spec.dir })
      else
        let s:jobs[name] = { 'running': 0, 'lines': ['Already installed'], 'error': 0 }
      endif
    else
      let s:jobs[name] = { 'running': 0, 'lines': s:lines(error), 'error': 1 }
    endif
  else
    let cmd = ['git', 'clone']
    if !has_tag
      call extend(cmd, s:clone_opt)
    endif
    if !empty(prog)
      call add(cmd, prog)
    endif
    call s:spawn(name, spec, [extend(cmd, [spec.uri, s:trim(spec.dir)]), function('s:checkout_command'), function('s:merge_command')], { 'new': 1 })
  endif

  if !s:jobs[name].running
    call s:reap(name)
  endif
  if len(s:jobs) >= s:update.threads
    break
  endif
endwhile
endfunction
"}}}

function! s:update_vim()
  let s:jobs = {}

  call s:bar()
  call s:tick()
endfunction

" function! s:update_impl(pull, force, args) abort
function! s:update_impl(pull, force, args) abort
"{{{
  let sync = index(a:args, '--sync') >= 0 || has('vim_starting')
  let args = filter(copy(a:args), 'v:val != "--sync"')
  let threads = (len(args) > 0 && args[-1] =~ '^[1-9][0-9]*$') ?
                  \ remove(args, -1) : get(g:, 'pmana_threads', 16)
  let managed = filter(deepcopy(g:pmanas), 's:is_managed(v:key)')
  let todo = empty(args) ? filter(managed, '!v:val.frozen || !isdirectory(v:val.dir)') :
                         \ filter(managed, 'index(args, v:key) >= 0')
  if empty(todo)
    return s:warn('echo', 'No pmanain to '. (a:pull ? 'update' : 'install'))
  endif
  "echom todo

  if !s:is_win && s:git_version_requirement(2, 3)
    let s:git_terminal_prompt = exists('$GIT_TERMINAL_PROMPT') ? $GIT_TERMINAL_PROMPT : ''
    let $GIT_TERMINAL_PROMPT = 0
    for pmana in values(todo)
      let pmana.uri = substitute(pmana.uri,
            \ '^https://git::@github\.com', 'https://github.com', '')
    endfor
  endif

  if !isdirectory(g:pmana_home)
    try
      call mkdir(g:pmana_home, 'p')
    catch
      return s:err(printf('Invalid pmana directory: %s. '.
              \ 'Try to call pmana#begin with a valid directory', g:pmana_home))
    endtry
  endif

  if has('nvim') && !exists('*jobwait') && threads > 1
    call s:warn('echom', '[vim-pmana] Update Neovim for parallel installer')
  endif

  let use_job = s:nvim || s:vim8
  let python = (has('python') || has('python3')) && !use_job
  let ruby = has('ruby') && !use_job && (v:version >= 703 || v:version == 702 && has('patch374')) && !(s:is_win && has('gui_running')) && threads > 1 && s:check_ruby()

  let s:update = {
    \ 'start':   reltime(),
    \ 'all':     todo,
    \ 'todo':    copy(todo),
    \ 'errors':  [],
    \ 'pull':    a:pull,
    \ 'force':   a:force,
    \ 'new':     {},
    \ 'threads': (python || ruby || use_job) ? min([len(todo), threads]) : 1,
    \ 'bar':     '',
    \ 'fin':     0
  \ }
"}}}


  call s:prepare(1)
  call append(0, ['', ''])
  normal! 2G
  silent! redraw

  " Set remote name, overriding a possible user git config's clone.defaultRemoteName
  let s:clone_opt = ['--origin', 'origin']
  if get(g:, 'pmana_shallow', 1)
    call extend(s:clone_opt, ['--depth', '1'])
    if s:git_version_requirement(1, 7, 10)
      call add(s:clone_opt, '--no-single-branch')
    endif
  endif

  if has('win32unix') || has('wsl')
    call extend(s:clone_opt, ['-c', 'core.eol=lf', '-c', 'core.autocrlf=input'])
  endif

  let s:submodule_opt = s:git_version_requirement(2, 8) ? ' --jobs='.threads : ''
  echom s:submodule_opt . "aaaa"

  " Python version requirement (>= 2.7)
  if python && !has('python3') && !ruby && !use_job && s:update.threads > 1
    redir => pyv
    silent python import platform; print platform.python_version()
    redir END
    let python = s:version_requirement(
          \ map(split(split(pyv)[0], '\.'), 'str2nr(v:val)'), [2, 6])
  endif

  "echom python
  "echom ruby
  "echom s:update.threads
  if (python || ruby) && s:update.threads > 1
    echom "True in (python || ruby) if..else"
   
    "{{{
    try
      let imd = &imd
      if s:mac_gui
        set noimd
      endif
      if ruby
        call s:update_ruby()
      else
        call s:update_python()
      endif
    catch
      let lines = getline(4, '$')
      let printed = {}
      silent! 4,$d _
      for line in lines
        let name = s:extract_name(line, '.', '')
        if empty(name) || !has_key(printed, name)
          call append('$', line)
          if !empty(name)
            let printed[name] = 1
            if line[0] == 'x' && index(s:update.errors, name) < 0
              call add(s:update.errors, name)
            end
          endif
        endif
      endfor
    finally
      let &imd = imd
      call s:update_finish()
    endtry
    "}}}
  else
    echom "False in (python || ruby) if..else"
    "call s:update_vim()
    "while use_job && sync
    "  sleep 100m
    "  if s:update.fin
    "    break
    "  endif
    "endwhile
  endif
endfunction


" function! s:clean(force){{{
function! s:clean(force)
  call s:prepare()
  call append(0, 'Searching for invalid pmanains in '.g:pmana_home)
  call append(1, '')

  " List of valid directories
  let dirs = []
  let errs = {}
  let [cnt, total] = [0, len(g:pmanas)]
  for [name, spec] in items(g:pmanas)
    if !s:is_managed(name) || get(spec, 'frozen', 0)
      call add(dirs, spec.dir)
    else
      let [err, clean] = s:git_validate(spec, 1)
      if clean
        let errs[spec.dir] = s:lines(err)[0]
      else
        call add(dirs, spec.dir)
      endif
    endif
    let cnt += 1
    call s:progress_bar(2, repeat('=', cnt), total)
    normal! 2G
    redraw
  endfor

  let allowed = {}
  for dir in dirs
    let allowed[s:dirpath(s:pmana_fnamemodify(dir, ':h:h'))] = 1
    let allowed[dir] = 1
    for child in s:glob_dir(dir)
      let allowed[child] = 1
    endfor
  endfor

  let todo = []
  let found = sort(s:glob_dir(g:pmana_home))
  while !empty(found)
    let f = remove(found, 0)
    if !has_key(allowed, f) && isdirectory(f)
      call add(todo, f)
      call append(line('$'), '- ' . f)
      if has_key(errs, f)
        call append(line('$'), '    ' . errs[f])
      endif
      let found = filter(found, 'stridx(v:val, f) != 0')
    end
  endwhile

  4
  redraw
  if empty(todo)
    call append(line('$'), 'Already clean.')
  else
    let s:clean_count = 0
    call append(3, ['Directories to delete:', ''])
    redraw!
    if a:force || s:ask_no_interrupt('Delete all directories?')
      call s:delete([6, line('$')], 1)
    else
      call setline(4, 'Cancelled.')
      nnoremap <silent> <buffer> d :set opfunc=<sid>delete_op<cr>g@
      nmap     <silent> <buffer> dd d_
      xnoremap <silent> <buffer> d :<c-u>call <sid>delete_op(visualmode(), 1)<cr>
      echo 'Delete the lines (d{motion}) to delete the corresponding directories'
    endif
  endif
  4
  setlocal nomodifiable
endfunction"}}}

function! s:upgrade()"{{{
  echo 'Downloading the latest version of vim-pmana'
  redraw
  let tmp = s:pmana_tempname()
  let new = tmp . '/pmana.vim'

  try
    let out = s:system(['git', 'clone', '--depth', '1', s:pmana_src, tmp])
    if v:shell_error
      return s:err('Error upgrading vim-pmana: '. out)
    endif

    if readfile(s:me) ==# readfile(new)
      echo 'vim-pmana is already up-to-date'
      return 0
    else
      call rename(s:me, s:me . '.old')
      call rename(new, s:me)
      unlet g:loaded_pmana
      echo 'vim-pmana has been upgraded'
      return 1
    endif
  finally
    silent! call s:rm_rf(tmp)
  endtry
endfunction"}}}

function! s:status()"{{{
  call s:prepare()
  call append(0, 'Checking pmanains')
  call append(1, '')

  let ecnt = 0
  let unloaded = 0
  let [cnt, total] = [0, len(g:pmanas)]
  for [name, spec] in items(g:pmanas)
    let is_dir = isdirectory(spec.dir)
    if has_key(spec, 'uri')
      if is_dir
        let [err, _] = s:git_validate(spec, 1)
        let [valid, msg] = [empty(err), empty(err) ? 'OK' : err]
      else
        let [valid, msg] = [0, 'Not found. Try PmanaInstall.']
      endif
    else
      if is_dir
        let [valid, msg] = [1, 'OK']
      else
        let [valid, msg] = [0, 'Not found.']
      endif
    endif
    let cnt += 1
    let ecnt += !valid
    " `s:loaded` entry can be missing if PmanaUpgraded
    if is_dir && get(s:loaded, name, -1) == 0
      let unloaded = 1
      let msg .= ' (not loaded)'
    endif
    call s:progress_bar(2, repeat('=', cnt), total)
    call append(3, s:format_message(valid ? '-' : 'x', name, msg))
    normal! 2G
    redraw
  endfor
  call setline(1, 'Finished. '.ecnt.' error(s).')
  normal! gg
  setlocal nomodifiable
  if unloaded
    echo "Press 'L' on each line to load pmanain, or 'U' to update"
    nnoremap <silent> <buffer> L :call <SID>status_load(line('.'))<cr>
    xnoremap <silent> <buffer> L :call <SID>status_load(line('.'))<cr>
  end
endfunction"}}}

" diff(){{{
function! s:diff()
  call s:prepare()
  call append(0, ['Collecting changes ...', ''])
  let cnts = [0, 0]
  let bar = ''
  let total = filter(copy(g:pmanas), 's:is_managed(v:key) && isdirectory(v:val.dir)')
  call s:progress_bar(2, bar, len(total))
  for origin in [1, 0]
    let pmanas = reverse(sort(items(filter(copy(total), (origin ? '' : '!').'(has_key(v:val, "commit") || has_key(v:val, "tag"))'))))
    if empty(pmanas)
      continue
    endif
    call s:append_ul(2, origin ? 'Pending updates:' : 'Last update:')
    for [k, v] in pmanas
      let branch = s:git_origin_branch(v)
      if len(branch)
        let range = origin ? '..origin/'.branch : 'HEAD@{1}..'
        let cmd = ['git', 'log', '--graph', '--color=never']
        if s:git_version_requirement(2, 10, 0)
          call add(cmd, '--no-show-signature')
        endif
        call extend(cmd, ['--pretty=format:%x01%h%x01%d%x01%s%x01%cr', range])
        if has_key(v, 'rtp')
          call extend(cmd, ['--', v.rtp])
        endif
        let diff = s:system_chomp(cmd, v.dir)
        if !empty(diff)
          let ref = has_key(v, 'tag') ? (' (tag: '.v.tag.')') : has_key(v, 'commit') ? (' '.v.commit) : ''
          call append(5, extend(['', '- '.k.':'.ref], map(s:lines(diff), 's:format_git_log(v:val)')))
          let cnts[origin] += 1
        endif
      endif
      let bar .= '='
      call s:progress_bar(2, bar, len(total))
      normal! 2G
      redraw
    endfor
    if !cnts[origin]
      call append(5, ['', 'N/A'])
    endif
  endfor
  call setline(1, printf('%d pmanain(s) updated.', cnts[0])
        \ . (cnts[1] ? printf(' %d pmanain(s) have pending updates.', cnts[1]) : ''))

  if cnts[0] || cnts[1]
    nnoremap <silent> <buffer> <pmana>(pmana-preview) :silent! call <SID>preview_commit()<cr>
    if empty(maparg("\<cr>", 'n'))
      nmap <buffer> <cr> <pmana>(pmana-preview)
    endif
    if empty(maparg('o', 'n'))
      nmap <buffer> o <pmana>(pmana-preview)
    endif
  endif
  if cnts[0]
    nnoremap <silent> <buffer> X :call <SID>revert()<cr>
    echo "Press 'X' on each block to revert the update"
  endif
  normal! gg
  setlocal nomodifiable
endfunction

function! s:snapshot(force, ...) abort
  call s:prepare()
  setf vim
  call append(0, ['" Generated by vim-pmana',
                \ '" '.strftime("%c"),
                \ '" :source this file in vim to restore the snapshot',
                \ '" or execute: vim -S snapshot.vim',
                \ '', '', 'PmanaUpdate!'])
  1
  let anchor = line('$') - 3
  let names = sort(keys(filter(copy(g:pmanas),
        \'has_key(v:val, "uri") && isdirectory(v:val.dir)')))
  for name in reverse(names)
    let sha = has_key(g:pmanas[name], 'commit') ? g:pmanas[name].commit : s:git_revision(g:pmanas[name].dir)
    if !empty(sha)
      call append(anchor, printf("silent! let g:pmanas['%s'].commit = '%s'", name, sha))
      redraw
    endif
  endfor

  if a:0 > 0
    let fn = s:pmana_expand(a:1)
    if filereadable(fn) && !(a:force || s:ask(a:1.' already exists. Overwrite?'))
      return
    endif
    call writefile(getline(1, '$'), fn)
    echo 'Saved as '.a:1
    silent execute 'e' s:esc(fn)
    setf vim
  endif
endfunction
"}}}

"function! s:lazy(pmana, opt){{{
function! s:lazy(pmana, opt)
  "echo "lazy:" . has_key(a:pmana, a:opt)
  "
  "return has_key(a:pmana, a:opt)
  return has_key(a:pmana, a:opt) &&
        \ (empty(s:to_a(a:pmana[a:opt]))         ||
        \  !isdirectory(a:pmana.dir)             ||
        \  len(s:glob(s:rtp(a:pmana), 'plugin')) ||
        \  len(s:glob(s:rtp(a:pmana), 'after/plugin')))
endfunction
"}}}

function! s:reload_pmanains()
  for name in s:loaded_names()
    call s:load_pmanain(g:pmanas[name])
  endfor
endfunction

function! s:load_pmanain(spec)
  call s:source(s:rtp(a:spec), 'plugin/**/*.vim', 'after/plugin/**/*.vim')
  if has('nvim-0.5.0')
    call s:source(s:rtp(a:spec), 'plugin/**/*.lua', 'after/plugin/**/*.lua')
  endif
endfunction

function! s:source(from, ...)
  let found = 0
  for pattern in a:000
    for vim in s:glob(a:from, pattern)
      execute 'source' s:esc(vim)
      let found = 1
    endfor
  endfor
  return found
endfunction

function! s:esc(path)
  return escape(a:path, ' ')
endfunction

" function! pmana#end(){{{
function! pmana#end()
  if !exists('g:pmanas')
    return s:err('pmana#end() called without calling pmana#begin() first')
  endif

  if exists('#PmanaLOD')
    augroup PmanaLOD
      autocmd!
    augroup END
    augroup! PmanaLOD
  endif
  let lod = { 'ft': {}, 'map': {}, 'cmd': {} }
  
"{{{
  if get(g:, 'did_load_filetypes', 0)
    filetype off
  endif

  for name in g:pmanas_order
    if !has_key(g:pmanas, name)
      continue
    endif
    let pmana = g:pmanas[name]
    "echom get(s:loaded, name, 0)
    if get(s:loaded, name, 0) || !s:lazy(pmana, 'on') && !s:lazy(pmana, 'for')
      let s:loaded[name] = 1
      continue
    endif

    if has_key(pmana, 'on')
      echom "has_key on"
      let s:triggers[name] = { 'map': [], 'cmd': [] }
      for cmd in s:to_a(pmana.on)
        if cmd =~? '^<Pmana>.\+'
          if empty(mapcheck(cmd)) && empty(mapcheck(cmd, 'i'))
            call s:assoc(lod.map, cmd, name)
          endif
          call add(s:triggers[name].map, cmd)
        elseif cmd =~# '^[A-Z]'
          let cmd = substitute(cmd, '!*$', '', '')
          if exists(':'.cmd) != 2
            call s:assoc(lod.cmd, cmd, name)
          endif
          call add(s:triggers[name].cmd, cmd)
        else
          call s:err('Invalid `on` option: '.cmd.
          \ '. Should start with an uppercase letter or `<Pmana>`.')
        endif
      endfor
    endif

    if has_key(pmana, 'for')
      echom "has_key for"
      let types = s:to_a(pmana.for)
      if !empty(types)
        augroup filetypedetect
        call s:source(s:rtp(pmana), 'ftdetect/**/*.vim', 'after/ftdetect/**/*.vim')
        if has('nvim-0.5.0')
          call s:source(s:rtp(pmana), 'ftdetect/**/*.lua', 'after/ftdetect/**/*.lua')
        endif
        augroup END
      endif
      for type in types
        call s:assoc(lod.ft, type, name)
      endfor
    endif
  endfor

  for [cmd, names] in items(lod.cmd)
    execute printf(
    \ 'command! -nargs=* -range -bang -complete=file %s call s:lod_cmd(%s, "<bang>", <line1>, <line2>, <q-args>, %s)',
    \ cmd, string(cmd), string(names))
  endfor

  for [map, names] in items(lod.map)
    for [mode, map_prefix, key_prefix] in
          \ [['i', '<C-\><C-O>', ''], ['n', '', ''], ['v', '', 'gv'], ['o', '', '']]
      execute printf(
      \ '%snoremap <silent> %s %s:<C-U>call <SID>lod_map(%s, %s, %s, "%s")<CR>',
      \ mode, map, map_prefix, string(map), string(names), mode != 'i', key_prefix)
    endfor
  endfor

  for [ft, names] in items(lod.ft)
    augroup PmanaLOD
      execute printf('autocmd FileType %s call <SID>lod_ft(%s, %s)',
            \ ft, string(ft), string(names))
    augroup END
  endfor
"}}}

  call s:reorg_rtp()
  filetype plugin indent on
  if has('vim_starting')
"    echom "aaaa"
    if has('syntax') && !exists('g:syntax_on')
      syntax enable
      echom "bbb"
    end
  else
    echom "ccc"
    "call s:reload_pmanains()
  endif
endfunction"}}}


"{{{
"function! s:remove_rtp()
"  for name in s:loaded_names()
"    let rtp = s:rtp(g:pmanas[name])
"    execute 'set rtp-='.s:escrtp(rtp)
"    let after = globpath(rtp, 'after')
"    if isdirectory(after)
"      execute 'set rtp-='.s:escrtp(after)
"    endif
"  endfor
"endfunction
"}}}

function! s:loaded_names()
  return filter(copy(g:pmanas_order), 'get(s:loaded, v:val, 0)')
endfunction

function! s:rtp(spec)
  "echom "in s:rtp"
  "echom a:spec.dir
  "echom get(a:spec, 'rtp', '')
  return s:path(a:spec.dir . get(a:spec, 'rtp', ''))
endfunction

"function! s:reorg_rtp(){{{
function! s:reorg_rtp()
  if !empty(s:first_rtp)
    execute 'set rtp-='.s:first_rtp
    execute 'set rtp-='.s:last_rtp
  endif

  " &rtp is modified from outside
  if exists('s:prtp') && s:prtp !=# &rtp
    call s:remove_rtp()
    unlet! s:middle
  endif

  let s:middle = get(s:, 'middle', &rtp)
  
  "echom "s:loader_names: "{{{
  "echom  s:loaded_names()
  "let rtps     = map(s:loaded_names(), 's:rtp(g:pmanas[v:val])')
  "echom "rtps: " . rtps
  "echo "bb"}}}
  let rtps     = map(s:loaded_names(), 's:rtp(g:pmanas[v:val])')
  let afters   = filter(map(copy(rtps), 'globpath(v:val, "after")'), '!empty(v:val)')
  let rtp      = join(map(rtps, 'escape(v:val, ",")'), ',')
                 \ . ','.s:middle.','
                 \ . join(map(afters, 'escape(v:val, ",")'), ',')
  let &rtp     = substitute(substitute(rtp, ',,*', ',', 'g'), '^,\|,$', '', 'g')
  let s:prtp   = &rtp

  if !empty(s:first_rtp)
    execute 'set rtp^='.s:first_rtp
    execute 'set rtp+='.s:last_rtp
  endif
endfunction"}}}


" function! s:parse_options(arg){{{
function! s:parse_options(arg)
  let opts = copy(s:base_spec)
  let type = type(a:arg)
  let opt_errfmt = 'Invalid argument for "%s" option of :Pmana (expected: %s)'
  if type == s:TYPE.string
    if empty(a:arg)
      throw printf(opt_errfmt, 'tag', 'string')
    endif
    let opts.tag = a:arg
  elseif type == s:TYPE.dict
    for opt in ['branch', 'tag', 'commit', 'rtp', 'dir', 'as']
      if has_key(a:arg, opt)
      \ && (type(a:arg[opt]) != s:TYPE.string || empty(a:arg[opt]))
        throw printf(opt_errfmt, opt, 'string')
      endif
    endfor
    for opt in ['on', 'for']
      if has_key(a:arg, opt)
      \ && type(a:arg[opt]) != s:TYPE.list
      \ && (type(a:arg[opt]) != s:TYPE.string || empty(a:arg[opt]))
        throw printf(opt_errfmt, opt, 'string or list')
      endif
    endfor
    if has_key(a:arg, 'do')
      \ && type(a:arg.do) != s:TYPE.funcref
      \ && (type(a:arg.do) != s:TYPE.string || empty(a:arg.do))
        throw printf(opt_errfmt, 'do', 'string or funcref')
    endif
    call extend(opts, a:arg)
    if has_key(opts, 'dir')
      let opts.dir = s:dirpath(s:pmana_expand(opts.dir))
    endif
  else
    throw 'Invalid argument type (expected: string or dictionary)'
  endif
  return opts
endfunction
"}}}

function! s:split_rtp()
  return split(&rtp, '\\\@<!,')
endfunction

function! s:escrtp(path)
  return escape(a:path, ' ,')
endfunction

let s:first_rtp = s:escrtp(get(s:split_rtp(), 0, ''))
let s:last_rtp  = s:escrtp(get(s:split_rtp(), -1, ''))




function! pmana#test()
"  return s:git_version_requirement(2, 3)
  call s:assgin_name()
endfunction
