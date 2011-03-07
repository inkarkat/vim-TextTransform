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

function! s:Transform(algorithm,type)
  let sel_save = &selection
  let cb_save = &clipboard
  set selection=inclusive clipboard-=unnamed
  let reg_save = @@
  let @@ = ''

  let types = type(a:type) == type([]) ? a:type : [a:type]
  for type in types
    if type == 'lines'
      silent exe 'normal! ^v'.v:count1.'$hy'
    elseif type =~ '^.$'
      silent exe "normal! `<" . type . "`>y"
    elseif type == 'char'
      silent exe "normal! `[v`]y"
    elseif type == 'line'
      silent exe "normal! '[V']y"
    elseif type == 'block'
      silent exe "normal! `[\<C-V>`]y"
    else
      silent exe 'normal y' . type
      if ! empty(@@)
        execute "normal! `[v`]h\<Esc>"
      endif
    endif
    "echomsg '****' string(type) string(@@)
    
    if empty(@@)
      continue
    endif

    let old = @@
    let @@ = {a:algorithm}(@@)
    if @@ !=# old
      normal! gvp
    endif
    break
  endfor

  let @@ = reg_save
  let &selection = sel_save
  let &clipboard = cb_save

  " silent! call repeat#set("\<Plug>unimpairedLine".a:algorithm,a:type)
endfunction

function! s:TransformOpfunc(type)
  return s:Transform(s:encode_algorithm, a:type)
endfunction

function! s:TransformSetup(algorithm)
  let s:encode_algorithm = a:algorithm
  let &opfunc = matchstr(expand('<sfile>'), '<SNR>\d\+_').'TransformOpfunc'
endfunction

function! TextTransform#MapTransform(map_options, key, algorithm, ...)
  exe 'nnoremap ' . a:map_options . ' <silent> <Plug>unimpaired'    .a:algorithm.' :<C-U>call <SID>TransformSetup("'.a:algorithm.'")<CR>g@'
  exe 'xnoremap ' . a:map_options . ' <silent> <Plug>unimpaired'    .a:algorithm.' :<C-U>call <SID>Transform("'.a:algorithm.'",visualmode())<CR>'

  let lineTypes = a:0 ? a:1 : 'lines'  
  exe 'nnoremap ' . a:map_options . ' <silent> <Plug>unimpairedLine'.a:algorithm.' :<C-U>call <SID>Transform('.string(a:algorithm).','.string(lineTypes).')<CR>'

  exe 'nmap ' . a:map_options . ' '.a:key.'  <Plug>unimpaired'.a:algorithm
  exe 'xmap ' . a:map_options . ' '.a:key.'  <Plug>unimpaired'.a:algorithm
  exe 'nmap ' . a:map_options . ' '.a:key.a:key[strlen(a:key)-1].' <Plug>unimpairedLine'.a:algorithm
endfunction

"call TextTransform#MapTransform('<buffer>', '[y', 'StringEncode')
"call TextTransform#MapTransform('<buffer>', ']y', 'StringDecode')

" vim: set ts=2 sts=0 sw=2 expandtab ff=unix fdm=syntax :
