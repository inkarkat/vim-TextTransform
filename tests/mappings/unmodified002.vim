" Test unmodified buffer due to no transformation. 

call TextTransform#MakeMappings('', '<Leader>sU', 'NoTransform')
call TextTransform#MakeMappings('', '<Leader>sV', 'MyTransform')
call vimtest#StartTap()
call vimtap#Plan(5)


call InsertExampleMultilineText('lines')
call vimtest#SaveOut()
call vimtap#Ok(! &modified, 'unmodified before')
normal \sU$
call vimtap#Ok(! &modified, 'unmodified after motion')
normal \sUU
call vimtap#Ok(! &modified, 'unmodified after line mapping')
normal vE\sU
call vimtap#Ok(! &modified, 'unmodified after visual-mode')
normal \sVV
call vimtap#Ok(&modified, 'finally modified')


call vimtest#Quit()
