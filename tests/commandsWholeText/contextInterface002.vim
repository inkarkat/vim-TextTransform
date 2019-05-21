" Test the TextTransformContext interface with different trigger positions.

call TextTransform#MakeCommand('', 'TransformIt', 'ContextEcho', { 'isProcessEntireText': 1 })


call InsertExampleMultilineText('same lines, different cursor')
3normal! 10|
2,4TransformIt

call InsertExampleMultilineText('once more, from near the end')
$-2normal! $
2,4TransformIt


call vimtest#Quit()
