" Test the TextTransformContext interface with different trigger positions.

call TextTransform#MakeMappings('', '<Leader>sU', 'ContextEcho')

function! InsertExampleMultilineTextAndEcho( description )
    echomsg a:description
    call InsertExampleMultilineText(a:description)
endfunction

call InsertExampleMultilineTextAndEcho('single line')
normal $\sUU

call InsertExampleMultilineTextAndEcho('character motion')
normal 3el\sU3b

call InsertExampleMultilineTextAndEcho('character textobject')
normal 2l\sU3iw

call InsertExampleMultilineTextAndEcho('line motion')
normal 0\sU+

call InsertExampleMultilineTextAndEcho('visual characterwise selection')
normal v3eo\sU

call InsertExampleMultilineTextAndEcho('visual linewise selection')
normal Vjo\sU

call InsertExampleMultilineTextAndEcho('visual blockwise selection')
execute "normal \<C-V>ejo\\sU"

call InsertExampleMultilineTextAndEcho('visual blockwise selection to end')
execute "normal \<C-V>$jo\\sU"


call vimtest#Quit()
