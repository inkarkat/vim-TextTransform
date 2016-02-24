" Test a transform command that affects only some lines. 
" Tests that the cursor is positioned on the last modified line. 
" Tests that the message only happens when more than 'report' lines have been
" changed. 

call TextTransform#MakeCommand('', 'TransformIt', 'TheTransform')


call InsertExampleMultilineText('some lines')
normal! gg$
2,4TransformIt
normal! i#

set report=1
call InsertExampleMultilineText('reported lines')
normal! gg$
2,4TransformIt
normal! i#


call vimtest#SaveOut()
call vimtest#Quit()
