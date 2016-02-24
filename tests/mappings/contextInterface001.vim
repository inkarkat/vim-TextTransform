" Test the TextTransformContext interface.

call TextTransform#MakeMappings('', '<Leader>sU', 'ContextEcho')

function! InsertExampleMultilineTextAndEcho( description )
    echomsg a:description
    call InsertExampleMultilineText(a:description)
endfunction

call InsertExampleMultilineTextAndEcho('single line')
normal \sUU

call InsertExampleMultilineTextAndEcho('character motion')
normal \sU3e

call InsertExampleMultilineTextAndEcho('line motion')
normal \sU+

call InsertExampleMultilineTextAndEcho('visual characterwise selection')
normal v3e\sU

call InsertExampleMultilineTextAndEcho('visual linewise selection')
normal Vj\sU

call InsertExampleMultilineTextAndEcho('visual blockwise selection')
execute "normal \<C-V>ej\\sU"

call InsertExampleMultilineTextAndEcho('visual blockwise selection to end')
execute "normal \<C-V>$j\\sU"


call vimtest#Quit()
