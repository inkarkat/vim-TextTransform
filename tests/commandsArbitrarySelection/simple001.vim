" Test a simple transform command on a text object selection.
" Tests that the cursor is positioned at the end of the text object.

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'MyTransform', 'aw')


call InsertExampleMultilineText('single text object')
TransformIt
normal! i#


call vimtest#SaveOut()
call vimtest#Quit()
