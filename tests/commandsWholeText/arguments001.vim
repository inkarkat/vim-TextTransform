" Test passing arguments to the command.

call TextTransform#MakeCommand('-nargs=*', 'TransformIt', 'ContextArgumentsMockTransform', { 'isProcessEntireText': 1 })

call vimtest#StartTap()
call vimtap#Plan(3)

call InsertExampleText('all text', 8)
let g:context = {'description': 'no arguments', 'arguments': []}
2TransformIt

let g:context = {'description': 'single argument', 'arguments': ['foo']}
4TransformIt foo

let g:context = {'description': 'multiple arguments', 'arguments': ['foo', 'bar', '42']}
6TransformIt foo bar 42

call vimtest#Quit()
