" Test no default mappings. 
" Tests that the default mappings aren't created when the key is empty. 
" Tests that mappings can be created using the <Plug> mappings after creating
" the mappings. 

call TextTransform#MakeMappings('', '', 'MyTransform')


call vimtest#StartTap()
call vimtap#Plan(3)
call vimtap#Is(maparg('\sU', 'n'), '', 'no normal-mode operator mapping')
call vimtap#Is(maparg('\sU', 'v'), '', 'no visual-mode mapping')
call vimtap#Is(maparg('\sUU', 'n'), '', 'no normal-mode line mapping')


nmap ,u <Plug>TextTMyTransformOperator
nmap ,U <Plug>TextTMyTransformLine
vmap ,u <Plug>TextTMyTransformVisual


call InsertExampleMultilineText('single line')
normal ,U

call InsertExampleMultilineText('character motion')
normal ,u3e

call InsertExampleMultilineText('line motion')
normal ,u+

call InsertExampleMultilineText('visual characterwise selection')
normal v3e,u

call InsertExampleMultilineText('visual linewise selection')
normal Vj,u

call InsertExampleMultilineText('visual blockwise selection')
execute "normal \<C-V>ej,u"


call vimtest#SaveOut()
call vimtest#Quit()
