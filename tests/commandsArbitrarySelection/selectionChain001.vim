" Test chain of text objects with line fallback. 

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'MyTransform', ["i'", 'i"', 'lines'])

call InsertExampleText('inner single quotes')
TransformIt

call InsertExampleText('inner double quotes')
normal! f-
TransformIt

call InsertExampleText('line')
normal! f/
TransformIt

call InsertExampleText('original')

call vimtest#SaveOut()
call vimtest#Quit()
