" Test passing arguments to the command.

call TextTransform#MakeSelectionCommand('-nargs=*', 'TransformIt', 'ContextArgumentsMockTransform', 'aw')

call vimtest#StartTap()
call vimtap#Plan(3)

call InsertExampleText('single text object', 4)
let g:context = {'description': 'no arguments', 'arguments': []}
TransformIt

let g:context = {'description': 'single argument', 'arguments': ['foo']}
normal! j
TransformIt foo

let g:context = {'description': 'multiple arguments', 'arguments': ['foo', 'bar', '42']}
normal! j
TransformIt foo bar 42

call vimtest#Quit()
