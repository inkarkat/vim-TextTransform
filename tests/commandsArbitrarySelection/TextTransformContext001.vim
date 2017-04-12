" Test the context object.

call TextTransform#MakeSelectionCommand('-bang -nargs=*', 'TransformIt', 'ContextMockTransform', 'aw')
call TextTransform#MakeSelectionCommand('-register', 'TransformReg', 'ContextMockTransform', 'aw')
call TextTransform#MakeSelectionCommand('', 'TransformAnother', 'MyTransform', 'aw')

call vimtest#StartTap()
call vimtap#Plan(36)

call InsertExampleText('single text object', 5)
let g:context = {'description': 'single text object', 'mapMode': 'c', 'mode': 'v', 'startPos': 17, 'endPos': 20, 'arguments': [], 'isBang': 0, 'register': '', 'isAlgorithmRepeat': 0, 'isRepeat': 0}
TransformIt
let g:context = {'description': 'single text object again', 'mapMode': 'c', 'mode': 'v', 'startPos': 17, 'endPos': 20, 'arguments': ['foo', 'bar'], 'isBang': 0, 'register': '', 'isAlgorithmRepeat': 1, 'isRepeat': 0}
normal! j
TransformIt foo bar

let g:context = {'description': 'single text object after another algorithm', 'mapMode': 'c', 'mode': 'v', 'startPos': 17, 'endPos': 20, 'arguments': ['gaga'], 'isBang': 1, 'register': '', 'isAlgorithmRepeat': 0, 'isRepeat': 0}
normal! j
TransformAnother
normal! j
TransformIt! gaga

let g:context = {'description': 'line with register', 'mapMode': 'c', 'mode': 'v', 'startPos': 17, 'endPos': 20, 'arguments': [], 'isBang': 0, 'register': 'd', 'isAlgorithmRepeat': 1, 'isRepeat': 0}
normal! j
TransformReg d

call vimtest#SaveOut()
call vimtest#Quit()
