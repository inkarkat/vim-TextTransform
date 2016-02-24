" Test operator-pending mapping N repetition with pure Vim features. 

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')


call InsertExampleText('doubled character motion', 3)
normal \sU2E
normal! j03W3.
normal! j03W.

call InsertExampleText('doubled command with single character motion', 3)
normal 2\sUE
normal! j03W3.
normal! j03W.


call vimtest#SaveOut()
call vimtest#Quit()
