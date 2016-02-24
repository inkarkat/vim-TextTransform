" Test passing arguments to the command.

call TextTransform#MakeCommand('-nargs=*', 'TransformIt', 'ContextArgumentsMockTransform')
call TextTransform#MakeCommand('', 'TransformAnother', 'ContextArgumentsMockTransform')

call vimtest#StartTap()
call vimtap#Plan(5)

call InsertExampleText('all text', 8)
let g:context = {'description': 'no arguments', 'arguments': []}
2TransformIt

let g:context = {'description': 'single argument', 'arguments': ['foo']}
4TransformIt foo

let g:context = {'description': 'multiple arguments', 'arguments': ['foo', 'bar', '42']}
6TransformIt foo bar 42

let g:context = {'description': 'no arguments possible', 'arguments': []}
8TransformAnother

call vimtap#err#ErrorsLike('^E488: ', '9TransformAnother foo bar', 'exception thrown')

call vimtest#Quit()
