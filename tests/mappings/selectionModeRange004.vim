" Test range selection mode not matching.

edit ../ranges.txt
call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', [['^Proin\>', '^NO-END$']])

25normal \sUU

8normal \sUU

call vimtest#SaveOut()
call vimtest#Quit()
