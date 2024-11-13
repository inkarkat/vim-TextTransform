" Test match inside range selection mode.

edit ../ranges.txt
call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', [['^BEGIN$', '^END$', '\<\w\{4}\s\w\+']])

25normal \sUU
14normal \sUU
6normal \sUU

call vimtest#SaveOut()
call vimtest#Quit()
