" Test a transform command that defaults to file range. 

call TextTransform#MakeCommand('-range=%', 'TransformIt', 'MyTransform')


call InsertExampleMultilineText('many lines')
normal! 3G
TransformIt
normal! i#


call vimtest#SaveOut()
call vimtest#Quit()
