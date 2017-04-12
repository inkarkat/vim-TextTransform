" TextTransform.vim: Create text transformation mappings and commands.
"
" DEPENDENCIES:
"   - TextTransform#Arbitrary.vim autoload script
"   - TextTransform#Lines.vim autoload script
"   - ingo/err.vim autoload script
"   - ingo/escape/command.vim autoload script
"
" Copyright: (C) 2011-2017 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"   Idea, design and implementation based on unimpaired.vim (vimscript #1590)
"   by Tim Pope.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.25.020	13-Apr-2017	Handle register: Pass on in <SID>Reselect.
"   1.25.019	27-May-2015	Add TextTransform#ToText() to handle non-String
"				results returned by the algorithm. Floats need
"				to be explicitly converted; Lists should be
"				flattened, too, to yield correct results for the
"				modification check with the original text. Dicts
"				and Funcrefs should not be returned and cause an
"				exception.
"   1.25.018	21-Mar-2015	FIX: Redefinition of l:SelectionModes inside
"				loop (since 1.12) may cause "E705: Variable name
"				conflicts with existing function" (in Vim
"				7.2.000). Move the variable definition out of
"				the loop.
"   1.25.017	02-Mar-2015	The selectionModes argument may (in /{pattern}/
"				form) contain special characters (e.g. "|" in
"				/foo\|bar/) that need escaping in order to
"				survive. Use ingo#escape#command#mapescape().
"   1.24.016	13-Jun-2014	ENH: Allow optional [!] for made commands, and
"				suppress the "Nothing transformed" error in that
"				case. This can help when using the resulting
"				command as an optional step, as prefixing with
"				:silent! can be difficult to combine with
"				ranges, and would suppress _all_ transformation
"				errors.
"   1.20.015	25-Sep-2013	Allow to pass command arguments, which are then
"				accessible to the algorithm through
"				g:TextTransformContext.arguments.
"   1.20.014	16-Sep-2013	Provide separate <Plug>TextR... repeat mappings
"				to be able to distinguish between a mapping and
"				its repeat via repeat.vim.
"   1.12.013	26-Jun-2013	Also perform the no-op check for the generated
"				commands. This avoids the attempted processing
"				and gives a better error message than the
"				current "E21: Cannot make changes, 'modifiable'
"				is off: 10,10delete _"
"				Abort commands in case of error.
"   1.12.012	14-Jun-2013	Minor: Make substitute() robust against
"				'ignorecase'.
"   1.04.011	28-Dec-2012	Minor: Correct lnum for no-modifiable buffer
"				check.
"   1.00.010	05-Apr-2012	Initial release.
"	010	19-Oct-2011	BUG: Variable rename from LineTypes to
"				l:selectionModes broke Funcref arguments; my
"				test suite would have caught this, if only I had
"				run it :-)
"	009	11-Apr-2011	Implement customization of mappings (by having
"				mappings to the <Plug>-mappings) and no custom
"				mappings (by passing an empty a:key), just the
"				<Plug>-mappings.
"	008	10-Apr-2011	Define commands with bang; otherwise,
"				buffer-local commands defined by ftplugins will
"				cause errors when the filetype changes (to one
"				that defines the same commands).
"	007	05-Apr-2011	Add TextTransform#MakeSelectionCommand() command
"				variant that uses s:Transform() and allows to
"				operate on text objects, motions, visual
"				selection, ...
"				Replace "unimpaired" prefix with "TextT" to
"				remove the last remnant of the original
"				unimpaired.vim script and make this fully
"				independent.
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
"	004	28-Mar-2011	ENH: Allow use of Funcref for a:algorithm in
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
    let l:noopModificationCheck = 'call <SID>Before()<Bar>call setline(".", getline("."))<Bar>call <SID>After()<Bar>'
    for [l:mappingName, l:isRepeat] in [[l:mappingName, 0], [l:repeatMappingName, 1]]
	execute printf('vnoremap <silent> %s <SID>%sVisual :<C-u>%scall TextTransform#Arbitrary#Visual(%s, %s, %d)<CR>',
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

	execute printf('nnoremap <silent> %s <Plug>%sLine :<C-u>%scall TextTransform#Arbitrary#Line(%s, %s, %s, %d)<CR>',
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
    execute printf('command -bar -bang -count %s %s call <SID>Before() | call setline(<line1>, getline(<line1>)) | call <SID>After() | if ! TextTransform#Arbitrary#Command(<line1>, <line2>, <bang>0, <q-register>, <count>, %s, %s, <f-args>) | if <bang>1 || ingo#err#Get() !=# "Nothing transformed" | echoerr ingo#err#Get() | endif | endif',
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
