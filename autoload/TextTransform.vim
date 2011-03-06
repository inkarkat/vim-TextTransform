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
  if a:type =~ '^\d\+$'
    silent exe 'norm! ^v'.a:type.'$hy'
  elseif a:type =~ '^.$'
    silent exe "normal! `<" . a:type . "`>y"
  elseif a:type == 'line'
    silent exe "normal! '[V']y"
  elseif a:type == 'block'
    silent exe "normal! `[\<C-V>`]y"
  else
    silent exe "normal! `[v`]y"
  endif
  let @@ = s:{a:algorithm}(@@)
  norm! gvp
  let @@ = reg_save
  let &selection = sel_save
  let &clipboard = cb_save
  if a:type =~ '^\d\+$'
    silent! call repeat#set("\<Plug>unimpairedLine".a:algorithm,a:type)
  endif
endfunction

function! s:TransformOpfunc(type)
  return s:Transform(s:encode_algorithm, a:type)
endfunction

function! s:TransformSetup(algorithm)
  let s:encode_algorithm = a:algorithm
  let &opfunc = matchstr(expand('<sfile>'), '<SNR>\d\+_').'TransformOpfunc'
endfunction

function! TextTransform#MapTransform(algorithm, key, ...)
  let map_options = a:0 ? a:1 : '' 
  exe 'nnoremap ' . map_options . ' <silent> <Plug>unimpaired'    .a:algorithm.' :<C-U>call <SID>TransformSetup("'.a:algorithm.'")<CR>g@'
  exe 'xnoremap ' . map_options . ' <silent> <Plug>unimpaired'    .a:algorithm.' :<C-U>call <SID>Transform("'.a:algorithm.'",visualmode())<CR>'
  exe 'nnoremap ' . map_options . ' <silent> <Plug>unimpairedLine'.a:algorithm.' :<C-U>call <SID>Transform("'.a:algorithm.'",v:count1)<CR>'
  exe 'nmap ' . map_options . ' '.a:key.'  <Plug>unimpaired'.a:algorithm
  exe 'xmap ' . map_options . ' '.a:key.'  <Plug>unimpaired'.a:algorithm
  exe 'nmap ' . map_options . ' '.a:key.a:key[strlen(a:key)-1].' <Plug>unimpairedLine'.a:algorithm
endfunction

"call TextTransform#MapTransform('StringEncode', '[y', '<buffer>')
"call TextTransform#MapTransform('StringDecode', ']y', '<buffer>')

" vim: set ts=2 sts=0 sw=2 expandtab ff=unix fdm=syntax :
