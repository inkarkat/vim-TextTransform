" Test final cursor position after mappings.

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')


call InsertExampleMultilineText('single line')
normal \sUU
normal! r*

call InsertExampleMultilineText('character motion')
normal \sU3e
normal! r*

call InsertExampleMultilineText('line motion')
normal \sU+
normal! r*

call InsertExampleMultilineText('visual characterwise selection')
normal v3e\sU
normal! r*

call InsertExampleMultilineText('visual characterwise selection from opposite')
normal v3eo\sU
normal! r*

call InsertExampleMultilineText('visual linewise selection')
normal Vj\sU
normal! r*

call InsertExampleMultilineText('visual linewise selection from opposite')
normal Vjo\sU
normal! r*

call InsertExampleMultilineText('visual blockwise selection')
execute "normal \<C-V>ej\\sU"
normal! r*

call InsertExampleMultilineText('visual blockwise selection from opposite')
execute "normal \<C-V>ejo\\sU"
normal! r*

call InsertExampleMultilineText('visual blockwise selection to end')
execute "normal \<C-V>$j\\sU"
normal! r*


call vimtest#SaveOut()
call vimtest#Quit()
