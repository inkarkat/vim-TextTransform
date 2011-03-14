" TextTransform.vim: Text transformations extracted from unimpaired. 
"
" DEPENDENCIES:
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION    DATE        REMARKS 
"	    001	    07-Mar-2011	file creation from plugin/unimpaired.vim

function! s:Transform( algorithm, selectionModes, onError )
  let l:save_view = winsaveview()
  let sel_save = &selection
  let cb_save = &clipboard
  set selection=inclusive clipboard-=unnamed
  let reg_save = @@
  let @@ = ''

  let l:selectionModes = type(a:selectionModes) == type([]) ? a:selectionModes : [a:selectionModes]
  for l:SelectionMode in l:selectionModes
    if type(l:SelectionMode) == type(function('tr'))
      if call(l:SelectionMode, [])
        silent normal! gvy
      endif
    elseif l:SelectionMode == 'lines'
      silent exe 'normal! ^v'.v:count1.'$hy'
    elseif l:SelectionMode =~ '^.$'
      silent exe "normal! `<" . l:SelectionMode . "`>y"
    elseif l:SelectionMode == 'char'
      silent exe "normal! `[v`]y"
    elseif l:SelectionMode == 'line'
      silent exe "normal! '[V']y"
    elseif l:SelectionMode == 'block'
      silent exe "normal! `[\<C-V>`]y"
    else
      silent exe 'normal y' . l:SelectionMode
      if ! empty(@@)
        execute "normal! `[v`]h\<Esc>"
      endif
    endif
    "echomsg '****' string(l:SelectionMode) string(@@)
    
    if empty(@@)
      unlet l:SelectionMode
      continue
    endif

    let old = @@
    let @@ = {a:algorithm}(@@)
    if @@ ==# old
      call winrestview(l:save_view)
      if a:onError ==# 'beep'
        execute "normal \<Plug>RingTheBell" 
      elseif a:onError ==# 'errmsg'
        let v:errmsg = 'Nothing transformed'
        echohl ErrorMsg
        echomsg v:errmsg
        echohl None
      endif
    else
      normal! gvp
    endif
    break
  endfor

  let @@ = reg_save
  let &selection = sel_save
  let &clipboard = cb_save

  " silent! call repeat#set("\<Plug>unimpairedLine".a:algorithm,a:selectionModes)
endfunction

function! s:TransformOpfunc(selectionMode)
  return s:Transform(s:encode_algorithm, a:selectionMode, 'beep')
endfunction

function! s:TransformSetup(algorithm)
  let s:encode_algorithm = a:algorithm
  let &opfunc = matchstr(expand('<sfile>'), '<SNR>\d\+_').'TransformOpfunc'
endfunction

function! TextTransform#MapTransform(map_options, key, algorithm, ...)
  exe 'nnoremap ' . a:map_options . ' <silent> <Plug>unimpaired'    .a:algorithm.' :<C-U>call <SID>TransformSetup("'.a:algorithm.'")<CR>g@'
  exe 'xnoremap ' . a:map_options . ' <silent> <Plug>unimpaired'    .a:algorithm.' :<C-U>call <SID>Transform("'.a:algorithm.'",visualmode(), "beep")<CR>'

  let LineTypes = a:0 ? a:1 : 'lines'  
  exe 'nnoremap ' . a:map_options . ' <silent> <Plug>unimpairedLine'.a:algorithm.' :<C-U>call <SID>Transform('.string(a:algorithm).','.string(LineTypes).', "beep")<CR>'

  exe 'nmap ' . a:map_options . ' '.a:key.'  <Plug>unimpaired'.a:algorithm
  exe 'xmap ' . a:map_options . ' '.a:key.'  <Plug>unimpaired'.a:algorithm
  exe 'nmap ' . a:map_options . ' '.a:key.a:key[strlen(a:key)-1].' <Plug>unimpairedLine'.a:algorithm
endfunction

"call TextTransform#MapTransform('<buffer>', '[y', 'StringEncode')
"call TextTransform#MapTransform('<buffer>', ']y', 'StringDecode')

function! TextTransform#MakeCommand( commandOptions, commandName, algorithm )
  " TODO
endfunction

" vim: set ts=2 sts=0 sw=2 expandtab ff=unix fdm=syntax :
