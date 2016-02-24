" Test the TextTransformContext interface.

call TextTransform#MakeCommand('', 'TransformIt', 'ContextEcho', { 'isProcessEntireText': 1 })


call InsertExampleMultilineText('lines')
normal! gg$
2,4TransformIt


call vimtest#Quit()
