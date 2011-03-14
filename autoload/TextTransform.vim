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
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers. 
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')
    let @@ = ''

    let l:selectionModes = type(a:selectionModes) == type([]) ? a:selectionModes : [a:selectionModes]
    for l:SelectionMode in l:selectionModes
	if type(l:SelectionMode) == type(function('tr'))
	    if call(l:SelectionMode, [])
		silent normal! gvy
	    endif
	elseif l:SelectionMode ==# 'lines'
	    silent execute 'normal! 0v' . v:count1 . '$y'
	elseif l:SelectionMode =~# '^.$'
	    silent execute "normal! `<" . l:SelectionMode . "`>y"
	elseif l:SelectionMode ==# 'char'
	    silent execute "normal! `[v`]y"
	elseif l:SelectionMode ==# 'line'
	    silent execute "normal! '[V']y"
	elseif l:SelectionMode ==# 'block'
	    silent execute "normal! `[\<C-V>`]y"
	else
	    silent execute 'normal y' . l:SelectionMode
	    if ! empty(@@)
		execute "normal! `[v`]\<Esc>"
	    endif
	endif
	"echomsg '****' string(l:SelectionMode) string(@@)
	
	if empty(@@)
	    unlet l:SelectionMode
	    continue
	endif

	let l:originalText = @@
	let @@ = {a:algorithm}(@@)
	if @@ ==# l:originalText
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

    call setreg('"', l:save_reg, l:save_regmode)
    let &clipboard = l:save_clipboard

    " silent! call repeat#set("\<Plug>unimpairedLine".a:algorithm,a:selectionModes)
endfunction

function! TextTransform#TransformOpfunc(selectionMode)
    return s:Transform(s:algorithm, a:selectionMode, 'beep')
endfunction

function! s:TransformSetup(algorithm)
  let s:algorithm = a:algorithm
  let &opfunc = 'TextTransform#TransformOpfunc'
endfunction

function! TextTransform#MapTransform(map_options, key, algorithm, ...)
    execute 'nnoremap ' . a:map_options . ' <silent> <Plug>unimpaired'    .a:algorithm.' :<C-U>call <SID>TransformSetup("'.a:algorithm.'")<CR>g@'
    execute 'xnoremap ' . a:map_options . ' <silent> <Plug>unimpaired'    .a:algorithm.' :<C-U>call <SID>Transform("'.a:algorithm.'",visualmode(), "beep")<CR>'

    let LineTypes = a:0 ? a:1 : 'lines'  
    execute 'nnoremap ' . a:map_options . ' <silent> <Plug>unimpairedLine'.a:algorithm.' :<C-U>call <SID>Transform('.string(a:algorithm).','.string(LineTypes).', "beep")<CR>'

    execute 'nmap ' . a:map_options . ' '.a:key.'  <Plug>unimpaired'.a:algorithm
    execute 'xmap ' . a:map_options . ' '.a:key.'  <Plug>unimpaired'.a:algorithm
    execute 'nmap ' . a:map_options . ' '.a:key.a:key[strlen(a:key)-1].' <Plug>unimpairedLine'.a:algorithm
endfunction

"call TextTransform#MapTransform('<buffer>', '[y', 'StringEncode')
"call TextTransform#MapTransform('<buffer>', ']y', 'StringDecode')

function! TextTransform#MakeCommand( commandOptions, commandName, algorithm )
    " TODO
endfunction

" vim: set ts=2 sts=0 sw=2 expandtab ff=unix fdm=syntax :
