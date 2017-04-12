" Test the context object.

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'ContextMockTransform', 'aw')
call TextTransform#MakeSelectionCommand('', 'TransformAnother', 'MyTransform', 'aw')

call vimtest#StartTap()
call vimtap#Plan(18)

call InsertExampleText('single text object', 4)
let g:context = {'description': 'single text object', 'mapMode': 'c', 'mode': 'v', 'startPos': 17, 'endPos': 20, 'isAlgorithmRepeat': 0, 'isRepeat': 0}
TransformIt
let g:context = {'description': 'single text object again', 'mapMode': 'c', 'mode': 'v', 'startPos': 17, 'endPos': 20, 'isAlgorithmRepeat': 1, 'isRepeat': 0}
normal! j
TransformIt

let g:context = {'description': 'single text object after another algorithm', 'mapMode': 'c', 'mode': 'v', 'startPos': 17, 'endPos': 20, 'isAlgorithmRepeat': 0, 'isRepeat': 0}
normal! j
TransformAnother
normal! j
TransformIt

call vimtest#SaveOut()
call vimtest#Quit()
