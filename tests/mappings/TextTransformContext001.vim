" Test the context object.

call TextTransform#MakeMappings('', '<Leader>sU', 'ContextMockTransform')


call vimtest#StartTap()
call vimtap#Plan(189)

call InsertExampleText('character motion', 2)
let g:context = {'description': 'character motion', 'mapMode': 'o', 'mode': 'v', 'startPos': 17, 'endPos': 104, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 0, 'isRepeat': 0}
normal \sU$
let g:context = {'description': 'character motion repeat', 'mapMode': 'o', 'mode': 'v', 'startPos': 17, 'endPos': 104, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 1, 'isRepeat': 1}
normal j03W.

call InsertExampleText('character motion with text object', 2)
let g:context = {'description': 'character motion with text object', 'mapMode': 'o', 'mode': 'v', 'startPos': 14, 'endPos': 22, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 0, 'isRepeat': 0}
normal \sUi'
let g:context = {'description': 'character motion with text object repeat', 'mapMode': 'o', 'mode': 'v', 'startPos': 14, 'endPos': 22, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 1, 'isRepeat': 1}
normal j03W.


call InsertExampleText('single line', 3)
let g:context = {'description': 'single line', 'mapMode': 'n', 'mode': 'v', 'startPos': 1, 'endPos': 104, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 0, 'isRepeat': 0}
normal \sUU
let g:context = {'description': 'single line repeat', 'mapMode': 'n', 'mode': 'v', 'startPos': 1, 'endPos': 104, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 1, 'isRepeat': 1}
normal j03W.


call InsertExampleText('characterwise', 3)
let g:context = {'description': 'visual characterwise', 'mapMode': 'v', 'mode': 'v', 'startPos': 17, 'endPos': 22, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 0, 'isRepeat': 0}
normal v2e\sU
let g:context = {'description': 'visual characterwise repeat', 'mapMode': 'v', 'mode': 'v', 'startPos': 17, 'endPos': 22, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 1, 'isRepeat': 1}
normal j03W.
let g:context = {'description': 'visual characterwise repeat', 'mapMode': 'v', 'mode': 'v', 'startPos': 31, 'endPos': 36, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 1, 'isRepeat': 1}
normal j06W.

call InsertExampleText('linewise', 6)
let g:context = {'description': 'visual linewise', 'mapMode': 'v', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 0, 'isRepeat': 0}
normal Vj\sU
let g:context = {'description': 'visual linewise repeat', 'mapMode': 'v', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 1, 'isRepeat': 1}
normal 3j03W.

call InsertExampleText('blockwise', 9)
let g:context = {'description': 'visual characterwise', 'mapMode': 'v', 'mode': "\<C-v>", 'startPos': 17, 'endPos': 22, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 0, 'isRepeat': 0}
execute "normal \<C-v>2ej\\sU"
let g:context = {'description': 'visual characterwise repeat', 'mapMode': 'v', 'mode': "\<C-v>", 'startPos': 17, 'endPos': 22, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 1, 'isRepeat': 1}
normal 3j03W.
let g:context = {'description': 'visual characterwise repeat', 'mapMode': 'v', 'mode': "\<C-v>", 'startPos': 31, 'endPos': 36, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 1, 'isRepeat': 1}
normal 3j06W.


call TextTransform#MakeMappings('', '<Leader>sV', 'MyTransform')
call InsertExampleText('another character motion', 4)
let g:context = {'description': 'character motion', 'mapMode': 'o', 'mode': 'v', 'startPos': 17, 'endPos': 104, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 0, 'isRepeat': 0}
normal \sU$
" Test that the repeat check actually distinguishes between re-typing the same
" TextTransform mapping and repeating via the "." command.
let g:context = {'description': 'character motion again', 'mapMode': 'o', 'mode': 'v', 'startPos': 17, 'endPos': 104, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 1, 'isRepeat': 0}
normal j\sU$
let g:context = {'description': 'character motion after another algorithm', 'mapMode': 'o', 'mode': 'v', 'startPos': 17, 'endPos': 104, 'arguments': [], 'isBang': 0, 'register': '"', 'isAlgorithmRepeat': 0, 'isRepeat': 0}
normal j\sV$
normal j\sU$

call InsertExampleText('with register', 4)
let g:context = {'description': 'visual characterwise', 'mapMode': 'v', 'mode': 'v', 'startPos': 17, 'endPos': 22, 'arguments': [], 'isBang': 0, 'register': 'a', 'isAlgorithmRepeat': 0, 'isRepeat': 0}
normal v2e"a\sU
let g:context = {'description': 'visual characterwise repeat', 'mapMode': 'v', 'mode': 'v', 'startPos': 17, 'endPos': 22, 'arguments': [], 'isBang': 0, 'register': 'a', 'isAlgorithmRepeat': 1, 'isRepeat': 1}
normal j03W.
let g:context = {'description': 'character motion', 'mapMode': 'o', 'mode': 'v', 'startPos': 17, 'endPos': 104, 'arguments': [], 'isBang': 0, 'register': 'b', 'isAlgorithmRepeat': 1, 'isRepeat': 0}
normal j"b\sU$
let g:context = {'description': 'character motion repeat', 'mapMode': 'o', 'mode': 'v', 'startPos': 17, 'endPos': 104, 'arguments': [], 'isBang': 0, 'register': 'b', 'isAlgorithmRepeat': 1, 'isRepeat': 1}
normal j03W.


call vimtest#SaveOut()
call vimtest#Quit()
