" Test algorithm returning non-String results.

call vimtest#StartTap()
call vimtap#Plan(2)

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'CannedTransform', 'lines')

unlet! g:Canned | let g:Canned = "foo\nbar\nbaz"
call InsertExampleMultilineText('String')
TransformIt

unlet! g:Canned | let g:Canned = ['foo', 'bar', 'baz']
call InsertExampleMultilineText('List')
TransformIt

unlet! g:Canned | let g:Canned = 123.456789
call InsertExampleMultilineText('Float')
TransformIt

unlet! g:Canned | let g:Canned = 123456
call InsertExampleMultilineText('Number')
TransformIt

unlet! g:Canned | let g:Canned = {'foo': 'bar'}
call InsertExampleMultilineText('Dict')
call vimtap#err#Errors('TextTransform: unsupported algorithm result type: 4', 'TransformIt', 'exception thrown on Dict')

unlet! g:Canned | let g:Canned = function('tr')
call InsertExampleMultilineText('Funcref')
call vimtap#err#Errors('TextTransform: unsupported algorithm result type: 2', 'TransformIt', 'exception thrown on Funcref')

call vimtest#SaveOut()
call vimtest#Quit()
