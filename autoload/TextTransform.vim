" TextTransform.vim: Create text transformation mappings and commands.
"
" DEPENDENCIES:
"   - ingo-library.vim plugin
"
" Copyright: (C) 2011-2019 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"   Idea, design and implementation based on unimpaired.vim (vimscript #1590)
"   by Tim Pope.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>

function! s:Before()
    let s:isModified = &l:modified
endfunction
function! s:After()
    if ! s:isModified
	setlocal nomodified
    endif
    unlet s:isModified
endfunction
nnoremap <expr> <SID>Reselect '1v' . (visualmode() !=# 'V' && &selection ==# 'exclusive' ? ' ' : '') . '"' . v:register
function! TextTransform#MakeMappings( mapArgs, key, algorithm, ... )
    let l:SelectionModes = (a:0 ? a:1 : 'lines')

    " This will cause "E474: Invalid argument" if the mapping name gets too long.
    let l:algorithmMappingName = (
    \	type(a:algorithm) == type('') ?
    \	    a:algorithm :
    \	    substitute(substitute(string(a:algorithm), '^\Cfunction(''\(.*\)'')', '\1', ''), '\C<SNR>', '', 'g')
    \)
    let l:mappingName = 'TextT' . l:algorithmMappingName
    let l:repeatMappingName = 'TextR' . l:algorithmMappingName
    let l:plugMappingName = '<Plug>' . l:mappingName

    execute printf('nnoremap <silent> <expr> %s %sOperator TextTransform#Arbitrary#Expression(%s, %s)',
    \	a:mapArgs,
    \	l:plugMappingName,
    \	string(a:algorithm),
    \	string(l:repeatMappingName)
    \)


    " Repeat not defined in visual mode.
    vnoremap <expr> <SID>TextTRecordPos TextTransform#Arbitrary#SetTriggerPos()
    let l:noopModificationCheck = 'call <SID>Before()<Bar>call setline(".", getline("."))<Bar>call <SID>After()<Bar>'
    for [l:mappingName, l:isRepeat] in [[l:mappingName, 0], [l:repeatMappingName, 1]]
	execute printf('vnoremap <silent> <script> %s <SID>%sVisual <SID>TextTRecordPos:<C-u>%scall TextTransform#Arbitrary#Visual(%s, %s, %d)<CR>',
	\   a:mapArgs,
	\   l:mappingName,
	\   l:noopModificationCheck,
	\   string(a:algorithm),
	\   string(l:repeatMappingName),
	\   l:isRepeat
	\)
	execute printf('vnoremap <silent> <script> <Plug>%sVisual <SID>%sVisual',
	\   l:mappingName,
	\   l:mappingName
	\)
	execute printf('nnoremap <silent> <script> <Plug>%sVisual <SID>Reselect<SID>%sVisual',
	\   l:mappingName,
	\   l:mappingName
	\)

	execute printf('nnoremap <silent> %s <Plug>%sLine :<C-u>%sif ! TextTransform#Arbitrary#Line(%s, %s, %s, %d)<Bar>echoerr ingo#err#Get()<Bar>endif<CR>',
	\   a:mapArgs,
	\   l:mappingName,
	\   l:noopModificationCheck,
	\   string(a:algorithm),
	\   ingo#escape#command#mapescape(string(l:SelectionModes)),
	\   string(l:repeatMappingName),
	\   l:isRepeat
	\)
    endfor


    if empty(a:key)
	return
    endif

    let l:operatorPlugMappingName = l:plugMappingName . 'Operator'
    if ! hasmapto(l:operatorPlugMappingName, 'n')
	execute 'nmap' a:mapArgs a:key l:operatorPlugMappingName
    endif

    let l:visualPlugMappingName = l:plugMappingName . 'Visual'
    if ! hasmapto(l:visualPlugMappingName, 'x')
	execute 'xmap' a:mapArgs a:key l:visualPlugMappingName
    endif

    let l:linePlugMappingName = l:plugMappingName . 'Line'
    if ! hasmapto(l:linePlugMappingName, 'n')
	let l:doubledKey = matchstr(a:key, '\(<[[:alpha:]-]\+>\|.\)$')
	execute 'nmap' a:mapArgs a:key . l:doubledKey l:linePlugMappingName
    endif
endfunction



function! TextTransform#MakeCommand( commandOptions, commandName, algorithm, ... )
    let l:options = (a:0 ? a:1 : {})
    execute printf('command! -bar -bang %s %s %s call <SID>Before() | call setline(<line1>, getline(<line1>)) | call <SID>After() | if ! TextTransform#Lines#TransformCommand(<line1>, <line2>, <bang>0, <q-register>, %s, %s, <f-args>) | if <bang>1 || ingo#err#Get() !=# "Nothing transformed" | echoerr ingo#err#Get() | endif | endif',
    \	a:commandOptions,
    \	(a:commandOptions =~# '\%(^\|\s\)-range\%(=\|\s\)' ? '' : '-range'),
    \	a:commandName,
    \	string(a:algorithm),
    \	string('TextTransform#Lines#Transform' . (get(l:options, 'isProcessEntireText', 0) ? 'WholeText' : 'Linewise'))
    \)
endfunction


function! TextTransform#MakeSelectionCommand( commandOptions, commandName, algorithm, selectionModes )
    execute printf('command -bar -bang -range=-1 -nargs=* %s %s call <SID>Before() | call setline(<line1>, getline(<line1>)) | call <SID>After() | if ! TextTransform#Arbitrary#Command(<line1>, <line2>, <bang>0, <q-register>, (<count> == -1 ? <q-args> : <count>), %s, %s, <f-args>) | if <bang>1 || ingo#err#Get() !=# "Nothing transformed" | echoerr ingo#err#Get() | endif | endif',
    \	a:commandOptions,
    \	a:commandName,
    \	string(a:algorithm),
    \	string(a:selectionModes)
    \)
endfunction

function! TextTransform#ToText( expr )
    if type(a:expr) == type('')
	return a:expr
    elseif type(a:expr) == type(0)
	return a:expr
    elseif type(a:expr) == type(0.0)
	return printf('%g', a:expr)   " Need to explicitly convert Float to avoid E806: using Float as a String
    elseif type(a:expr) == type([])
	return join(a:expr, "\n")   " Render List as String to yield correct results for the modification check with the original text. The actual required format for multi-line results depends on the further processing.
    else
	throw 'unsupported algorithm result type: ' . type(a:expr)
    endif
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
