" Test a simple transform command on a text object selection.
" Tests that the cursor is positioned at the beginning of the text object.

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'MyTransform', 'aw')


call InsertExampleMultilineText('multiple text object')
2TransformIt
normal! r#


call vimtest#SaveOut()
call vimtest#Quit()
