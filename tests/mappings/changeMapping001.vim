" Test change of default mappings. 
" Tests that the default mappings aren't created when different mappings to the
" <Plug> mappings exist. 

nmap ,u <Plug>TextTMyTransformOperator
nmap ,U <Plug>TextTMyTransformLine
vmap ,u <Plug>TextTMyTransformVisual

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')


call vimtest#StartTap()
call vimtap#Plan(3)
call vimtap#Is(maparg('\sU', 'n'), '', 'no normal-mode operator mapping')
call vimtap#Is(maparg('\sU', 'v'), '', 'no visual-mode mapping')
call vimtap#Is(maparg('\sUU', 'n'), '', 'no normal-mode line mapping')


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
