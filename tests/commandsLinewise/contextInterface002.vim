" Test the TextTransformContext interface with different trigger positions.

call TextTransform#MakeCommand('', 'TransformIt', 'ContextEcho')

function! InsertExampleMultilineTextAndEcho( description )
    echomsg a:description
    call InsertExampleMultilineText(a:description)
endfunction

call InsertExampleMultilineTextAndEcho('same line, different cursor')
3normal! 10|
2TransformIt

call InsertExampleMultilineTextAndEcho('multiple lines, from near the end')
$-2normal! $
2,4TransformIt


call vimtest#Quit()
