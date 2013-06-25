" Test error on no transformation. 
" Tests that the cursor position is kept. 

call TextTransform#MakeCommand('', 'TransformIt', 'NoTransform')


call InsertExampleMultilineText('many lines')
normal! gg$
2,4TransformIt
normal! i#


call vimtest#SaveOut()
call vimtest#Quit()
