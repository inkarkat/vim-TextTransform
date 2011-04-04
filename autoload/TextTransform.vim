" TextTransform.vim: Text transformations extracted from unimpaired. 
"
" DEPENDENCIES:
"   - TextTransform#Arbitrary.vim autoload script. 
"   - TextTransform#Lines.vim autoload script. 
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	006	05-Apr-2011	Limit the amount of script that gets sourced
"				when commands / mappings are defined during Vim
"				startup: 
"				Extract actual transformations on lines to
"				TextTransform#Lines.vim. 
"			    	Extract actual transformations in mappings to
"			    	TextTransform#Arbitrary.vim. 
"	005	29-Mar-2011	Rename TextTransform#MapTransform() to
"				TextTransform#MakeMappings(). 
"				Implement 'isProcessEntireText' option. 
"				Factor out s:TransformCommand() function and
"				make it delegate to the passed
"				a:ProcessFunction, which is either
"				s:TransformLinewise() or s:TransformWholeText(). 
"	004	28-Mar-2011	ENH: Allow use of funcref for a:algorithm in
"				order to support script-local transformation
"				functions. 
"	003	25-Mar-2011	ENH: Use s:TransformExpression() instead of
"				s:TransformSetup() to enable passing <count>
"				before the operator-pending mapping. 
"				Tighten pattern to detect visualmode() arguments
"				in s:Transform(). 
"				Implement TextTransform#MakeCommand() for
"				linewise application of the algorithm. 
"				ENH: Catch and report errors in algorithm. 
"				ENH: Do not make the buffer modified if no
"				transformation is done. 
"	002	16-Mar-2011	Fix off-by-one errors with some modes and
"				'selection' settings. 
"				FIX: Parsing for l:doubledKey now also accepts
"				key modifiers like "<S-...>". 
"	001	07-Mar-2011	file creation from plugin/unimpaired.vim

function! s:Before()
    let s:isModified = &l:modified
endfunction
function! s:After()
    if ! s:isModified
	setlocal nomodified
    endif
    unlet s:isModified
endfunction
nnoremap <expr> <SID>Reselect '1v' . (visualmode() !=# 'V' && &selection ==# 'exclusive' ? ' ' : '')
function! TextTransform#MakeMappings( mapArgs, key, algorithm, ... )
    " This will cause "E474: Invalid argument" if the mapping name gets too long. 
    let l:mappingName = 'unimpaired' . (
    \	type(a:algorithm) == type('') ?
    \	    a:algorithm :
    \	    substitute(substitute(string(a:algorithm), '^function(''\(.*\)'')', '\1', ''), '<SNR>', '', 'g')
    \)
    let l:plugMappingName = '<Plug>' . l:mappingName
    let l:noopModificationCheck = 'call <SID>Before()<Bar>call setline(1, getline(1))<Bar>call <SID>After()<Bar>'

    execute printf('nnoremap <silent> <expr> %s %sOperator TextTransform#Arbitrary#Expression(%s, %s)',
    \	a:mapArgs,
    \	l:plugMappingName,
    \	string(a:algorithm),
    \	string(l:mappingName)
    \)

    " Repeat not defined in visual mode. 
    execute printf('vnoremap <silent> %s <SID>%sVisual :<C-u>%scall TextTransform#Arbitrary#Visual(%s, %s)<CR>',
    \	a:mapArgs,
    \	l:mappingName,
    \	l:noopModificationCheck,
    \	string(a:algorithm),
    \	string(l:mappingName)
    \)
    execute printf('vnoremap <silent> <script> %sVisual <SID>%sVisual',
    \	l:plugMappingName,
    \	l:mappingName
    \)
    execute printf('nnoremap <silent> <script> %sVisual <SID>Reselect<SID>%sVisual',
    \	l:plugMappingName,
    \	l:mappingName
    \)

    let LineTypes = a:0 ? a:1 : 'lines'  
    execute printf('nnoremap <silent> %s %sLine :<C-u>%scall TextTransform#Arbitrary#Line(%s, %s, %s)<CR>',
    \	a:mapArgs,
    \	l:plugMappingName,
    \	l:noopModificationCheck,
    \	string(a:algorithm),
    \	string(LineTypes),
    \	string(l:mappingName)
    \)


    execute 'nmap' a:mapArgs a:key l:plugMappingName . 'Operator'
    execute 'xmap' a:mapArgs a:key l:plugMappingName . 'Visual'
    let l:doubledKey = matchstr(a:key, '\(<[[:alpha:]-]\+>\|.\)$')
    execute 'nmap' a:mapArgs a:key . l:doubledKey l:plugMappingName . 'Line'
endfunction


function! TextTransform#MakeCommand( commandOptions, commandName, algorithm, ... )
    let l:options = (a:0 ? a:1 : {})
    execute printf('command -bar %s %s %s call TextTransform#Lines#TransformCommand(<line1>, <line2>, %s, %s)',
    \	a:commandOptions,
    \	(a:commandOptions =~# '\%(^\|\s\)-range\%(=\|\s\)' ? '' : '-range'),
    \	a:commandName,
    \	string(a:algorithm),
    \	string('TextTransform#Lines#Transform' . (get(l:options, 'isProcessEntireText', 0) ? 'WholeText' : 'Linewise'))
    \)
endfunction

"TODO: Command variant that uses s:Transform() and allows to operate on text
" objects, motions, visual selection, ...
function! TextTransform#MakeSelectionCommand( commandOptions, commandName, algorithm, selectionModes )
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
