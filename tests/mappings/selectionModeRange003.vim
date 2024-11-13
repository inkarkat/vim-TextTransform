" Test range selection mode at unsuitable locations.

edit ../ranges.txt
call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', [[['^BEGIN$', '+1'], ['^END$', '-1']]])

" Empty range; due to the offsets selects the borders, too.
19normal \sUU

" In between two ranges; selects both.
8normal \sUU

call vimtest#SaveOut()
call vimtest#Quit()
