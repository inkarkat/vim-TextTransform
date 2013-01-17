" Test commands on visual modes. 

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'MyTransform', 'aw')


call InsertExampleMultilineText('visual characterwise selection')
execute "normal! v3e:TransformIt\<CR>"

call InsertExampleMultilineText('visual linewise selection')
execute "normal! Vj:TransformIt\<CR>"

call InsertExampleMultilineText('visual blockwise selection')
execute "normal! \<C-V>ej:TransformIt\<CR>"


call vimtest#SaveOut()
call vimtest#Quit()
