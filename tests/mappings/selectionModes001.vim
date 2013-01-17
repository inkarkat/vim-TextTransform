" Test all built-in selection modes. 

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')


call InsertExampleMultilineText('single line')
normal \sUU

call InsertExampleMultilineText('character motion')
normal \sU3e

call InsertExampleMultilineText('line motion')
normal \sU+

call InsertExampleMultilineText('visual characterwise selection')
normal v3e\sU

call InsertExampleMultilineText('visual linewise selection')
normal Vj\sU

call InsertExampleMultilineText('visual blockwise selection')
execute "normal \<C-V>ej\\sU"


call vimtest#SaveOut()
call vimtest#Quit()
