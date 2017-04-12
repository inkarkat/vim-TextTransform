" Test the context object.

call TextTransform#MakeCommand('', 'TransformIt', 'ContextMockTransform')
call TextTransform#MakeCommand('', 'TransformAnother', 'MyTransform')


call vimtest#StartTap()
call vimtap#Plan(36)

call InsertExampleText('all text', 10)
let g:context = [
\   {'description': 'lines', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'isAlgorithmRepeat': 0, 'isRepeat': 0},
\   {'description': 'lines', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'isAlgorithmRepeat': 0, 'isRepeat': 1},
\   {'description': 'lines', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'isAlgorithmRepeat': 0, 'isRepeat': 1}
\]
2,4TransformIt

let g:context = [
\   {'description': 'lines again', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'isAlgorithmRepeat': 1, 'isRepeat': 0},
\   {'description': 'lines again', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'isAlgorithmRepeat': 1, 'isRepeat': 1}
\]
6,7TransformIt


let g:context = {'description': 'lines after another algorithm', 'mapMode': 'c', 'mode': 'V', 'startPos': 1, 'endPos': 0x7FFFFFFF, 'isAlgorithmRepeat': 0, 'isRepeat': 0}
9TransformAnother
10TransformIt

call vimtest#SaveOut()
call vimtest#Quit()
