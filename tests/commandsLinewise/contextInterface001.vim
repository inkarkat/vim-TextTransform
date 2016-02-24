" Test the TextTransformContext interface.

call TextTransform#MakeCommand('', 'TransformIt', 'ContextEcho')

function! InsertExampleMultilineTextAndEcho( description )
    echomsg a:description
    call InsertExampleMultilineText(a:description)
endfunction

call InsertExampleMultilineTextAndEcho('single line')
normal! gg$
2TransformIt

call InsertExampleMultilineTextAndEcho('many lines')
normal! gg$
2,4TransformIt


call vimtest#Quit()
