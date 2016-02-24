" Test unmodified buffer due to no transformation after command. 

call TextTransform#MakeCommand('', 'TransformNo', 'NoTransform')
call TextTransform#MakeCommand('', 'TransformIt', 'MyTransform')
call vimtest#StartTap()
call vimtap#Plan(3)


call InsertExampleMultilineText('all lines')
call vimtest#SaveOut()
call vimtap#Ok(! &modified, 'unmodified before')
normal! gg$
2,4TransformNo
call vimtap#Ok(! &modified, 'unmodified after no-op command')
2,4TransformIt
call vimtap#Ok(&modified, 'modified after active command')


call vimtest#Quit()
