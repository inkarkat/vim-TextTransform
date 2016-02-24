" Test a simple transform command. 
" Tests that the cursor is positioned on the last modified line. 

call TextTransform#MakeCommand('', 'TransformIt', 'MyTransform', { 'isProcessEntireText': 1 })


call InsertExampleMultilineText('single line')
normal! gg$
2TransformIt
normal! i#

call InsertExampleMultilineText('many lines')
normal! gg$
2,4TransformIt
normal! i#


call vimtest#SaveOut()
call vimtest#Quit()
