" Test the context object.

call TextTransform#MakeCommand('-bang -nargs=*', 'TransformIt', 'ContextMockTransform')
call TextTransform#MakeCommand('-register', 'TransformReg', 'ContextMockTransform')
call TextTransform#MakeCommand('', 'TransformAnother', 'MyTransform')


call vimtest#StartTap()
call vimtap#Plan(63)

call InsertExampleText('all text', 11)
let g:context = [
\   {'description': 'lines', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'arguments': ['foo', 'bar'], 'isBang': 0, 'register': '', 'isAlgorithmRepeat': 0, 'isRepeat': 0},
\   {'description': 'lines', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'arguments': ['foo', 'bar'], 'isBang': 0, 'register': '', 'isAlgorithmRepeat': 0, 'isRepeat': 1},
\   {'description': 'lines', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'arguments': ['foo', 'bar'], 'isBang': 0, 'register': '', 'isAlgorithmRepeat': 0, 'isRepeat': 1}
\]
2,4TransformIt foo bar

let g:context = [
\   {'description': 'lines again', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'arguments': ['gaga'], 'isBang': 1, 'register': '', 'isAlgorithmRepeat': 1, 'isRepeat': 0},
\   {'description': 'lines again', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'arguments': ['gaga'], 'isBang': 1, 'register': '', 'isAlgorithmRepeat': 1, 'isRepeat': 1}
\]
6,7TransformIt! gaga


let g:context = {'description': 'lines after another algorithm', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'arguments': [], 'isBang': 0, 'register': '', 'isAlgorithmRepeat': 0, 'isRepeat': 0}
9TransformAnother
10TransformIt

let g:context = {'description': 'line with register', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'arguments': [], 'isBang': 0, 'register': 'd', 'isAlgorithmRepeat': 1, 'isRepeat': 0}
11TransformReg d

call vimtest#SaveOut()
call vimtest#Quit()
