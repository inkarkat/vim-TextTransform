" Test the context object.

function! ContextMockTransform( text )
    call vimtap#Is(g:TextTransformContext.mapMode,           s:context.mapMode,           s:context.description . ' - ' . 'mapMode')
    call vimtap#Is(g:TextTransformContext.mode,              s:context.mode,              s:context.description . ' - ' . 'mode')
    call vimtap#Is(g:TextTransformContext.startPos[2],       s:context.startPos,          s:context.description . ' - ' . 'startPos')
    call vimtap#Is(g:TextTransformContext.endPos[2],         s:context.endPos,            s:context.description . ' - ' . 'endPos')
    call vimtap#Is(g:TextTransformContext.isAlgorithmRepeat, s:context.isAlgorithmRepeat, s:context.description . ' - ' . 'isAlgorithmRepeat')

    return MyTransform(a:text)
endfunction
call TextTransform#MakeMappings('', '<Leader>sU', 'ContextMockTransform')


call vimtest#StartTap()
call vimtap#Plan(80)

call InsertExampleText('character motion', 2)
let s:context = {'description': 'character motion', 'mapMode': 'o', 'mode': 'v', 'startPos': 17, 'endPos': 104, 'isAlgorithmRepeat': 0}
normal \sU$
let s:context = {'description': 'character motion repeat', 'mapMode': 'o', 'mode': 'v', 'startPos': 17, 'endPos': 104, 'isAlgorithmRepeat': 1}
normal j03W.

call InsertExampleText('character motion with text object', 2)
let s:context = {'description': 'character motion with text object', 'mapMode': 'o', 'mode': 'v', 'startPos': 14, 'endPos': 22, 'isAlgorithmRepeat': 0}
normal \sUi'
let s:context = {'description': 'character motion with text object repeat', 'mapMode': 'o', 'mode': 'v', 'startPos': 14, 'endPos': 22, 'isAlgorithmRepeat': 1}
normal j03W.


call InsertExampleText('single line', 3)
let s:context = {'description': 'single line', 'mapMode': 'n', 'mode': 'v', 'startPos': 1, 'endPos': 104, 'isAlgorithmRepeat': 0}
normal \sUU
let s:context = {'description': 'single line repeat', 'mapMode': 'n', 'mode': 'v', 'startPos': 1, 'endPos': 104, 'isAlgorithmRepeat': 1}
normal j03W.


call InsertExampleText('characterwise', 3)
let s:context = {'description': 'visual characterwise', 'mapMode': 'v', 'mode': 'v', 'startPos': 17, 'endPos': 22, 'isAlgorithmRepeat': 0}
normal v2e\sU
let s:context = {'description': 'visual characterwise repeat', 'mapMode': 'v', 'mode': 'v', 'startPos': 17, 'endPos': 22, 'isAlgorithmRepeat': 1}
normal j03W.
let s:context = {'description': 'visual characterwise repeat', 'mapMode': 'v', 'mode': 'v', 'startPos': 31, 'endPos': 36, 'isAlgorithmRepeat': 1}
normal j06W.

call InsertExampleText('linewise', 6)
let s:context = {'description': 'visual linewise', 'mapMode': 'v', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'isAlgorithmRepeat': 0}
normal Vj\sU
let s:context = {'description': 'visual linewise repeat', 'mapMode': 'v', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'isAlgorithmRepeat': 1}
normal 3j03W.

call InsertExampleText('blockwise', 9)
let s:context = {'description': 'visual characterwise', 'mapMode': 'v', 'mode': "\<C-v>", 'startPos': 17, 'endPos': 22, 'isAlgorithmRepeat': 0}
execute "normal \<C-v>2ej\\sU"
let s:context = {'description': 'visual characterwise repeat', 'mapMode': 'v', 'mode': "\<C-v>", 'startPos': 17, 'endPos': 22, 'isAlgorithmRepeat': 1}
normal 3j03W.
let s:context = {'description': 'visual characterwise repeat', 'mapMode': 'v', 'mode': "\<C-v>", 'startPos': 31, 'endPos': 36, 'isAlgorithmRepeat': 1}
normal 3j06W.


call TextTransform#MakeMappings('', '<Leader>sV', 'MyTransform')
call InsertExampleText('another character motion', 3)
let s:context = {'description': 'character motion', 'mapMode': 'o', 'mode': 'v', 'startPos': 17, 'endPos': 104, 'isAlgorithmRepeat': 0}
normal \sU$
let s:context = {'description': 'character motion again', 'mapMode': 'o', 'mode': 'v', 'startPos': 17, 'endPos': 104, 'isAlgorithmRepeat': 1}
normal j\sU$
let s:context = {'description': 'character motion another algorithm', 'mapMode': 'o', 'mode': 'v', 'startPos': 17, 'endPos': 104, 'isAlgorithmRepeat': 0}
normal j\sV$


call vimtest#SaveOut()
call vimtest#Quit()
