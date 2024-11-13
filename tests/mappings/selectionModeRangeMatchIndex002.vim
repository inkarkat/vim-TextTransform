" Test indexed match inside range selection mode not matching.

edit ../ranges.txt
call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', [[['^BEGIN$', '-1'], ['^END$', '+1'], '\<\w\{4}\s\w\+', 3]])

" This one matches.
25normal \sUU

" These don't.
14normal \sUU
6normal \sUU

call vimtest#SaveOut()
call vimtest#Quit()
