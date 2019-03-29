" Test indexed match inside range selection mode.

edit ../ranges.txt
call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', [['^BEGIN$', '^END$', '\<\w\{4}\s\w\+', 2]])
25normal \sUU

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', [['^BEGIN$', '^END$', '\<\w\{4}\s\w\+', -1]])
14normal \sUU
6normal \sUU

call vimtest#SaveOut()
call vimtest#Quit()
