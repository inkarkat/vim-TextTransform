" Test algorithm returning multiple lines.

set report=2    " Tests that added lines are reported, even though only one line is transformed.

call TextTransform#MakeCommand('', 'TransformIt', 'CannedTransform')

unlet! g:Canned | let g:Canned = "foo\nbar\nbaz"
call InsertExampleMultilineText('multi')
2,3TransformIt
normal! i#

call vimtest#SaveOut()
call vimtest#Quit()
