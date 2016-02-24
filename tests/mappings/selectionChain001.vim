" Test chain of text objects with line fallback. 

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', ["i'", 'i"', 'lines'])

call InsertExampleText('inner single quotes')
normal \sUU

call InsertExampleText('inner double quotes')
normal f-\sUU

call InsertExampleText('line')
normal f/\sUU

call InsertExampleText('original')

call vimtest#SaveOut()
call vimtest#Quit()
