" Test transform command influenced by processEntireText option. 
" Tests that each line is transformed individually. 
" Tests that the cursor is positioned on the last modified line. 

call TextTransform#MakeCommand('', 'TransformIt', 'MarkBoundaries', { 'isProcessEntireText': 0 })


set report=1
call InsertExampleMultilineText('lines')
normal! gg$
2,4TransformIt
normal! i#

call vimtest#SaveOut()
call vimtest#Quit()
