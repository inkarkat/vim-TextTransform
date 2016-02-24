" Test default range of the transform command. 

call TextTransform#MakeCommand('', 'TransformIt', 'MyTransform')


call InsertExampleMultilineText('many lines')
normal! 3G
TransformIt
normal! i#


call vimtest#SaveOut()
call vimtest#Quit()
