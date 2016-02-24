" Test cursor positioning of transform command. 
" Tests that the cursor is positioned on the last modified line. 
" Tests that the cursor is positioned on the first non-blank "^ motion", like
" :substitute does, even with :set nostartofline. 

call TextTransform#MakeCommand('', 'TransformIt', 'TheTransform', { 'isProcessEntireText': 1 })


call InsertExampleMultilineText('many indented lines')
set nostartofline
normal! 2G>G
normal! gg$
2,4TransformIt
normal! i#


call vimtest#SaveOut()
call vimtest#Quit()
