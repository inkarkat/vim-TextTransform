" Test that the transformation does not affect the jump list.

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')


call InsertExampleMultilineText('character motion')
global/^$/call setline('.', '_')
normal! ggG
normal! 2G03W
normal \sU3e
execute "normal! jj\<C-o>r1\<C-o>r2"


call vimtest#SaveOut()
call vimtest#Quit()
