" Test unmodified buffer due to no selection. 

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', "i'")
call vimtest#StartTap()
call vimtap#Plan(3)


call InsertExampleMultilineText('lines')
call vimtest#SaveOut()
call vimtap#Ok(! &modified, 'unmodified before')
normal $\sUU
call vimtap#Ok(! &modified, 'unmodified after')
normal j0\sUU
call vimtap#Ok(&modified, 'finally modified')


call vimtest#Quit()
