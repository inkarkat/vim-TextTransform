" Test algorithm returning non-String results.

call TextTransform#MakeMappings('', '<Leader>sU', 'CannedTransform')

unlet! g:Canned | let g:Canned = "foo\nbar\nbaz"
call InsertExampleMultilineText('String')
normal \sUU

unlet! g:Canned | let g:Canned = ['foo', 'bar', 'baz']
call InsertExampleMultilineText('List')
normal \sUU

unlet! g:Canned | let g:Canned = 123.456789
call InsertExampleMultilineText('Float')
normal \sUU

unlet! g:Canned | let g:Canned = 123456
call InsertExampleMultilineText('Number')
normal \sUU

echomsg 'Test: Dict'
unlet! g:Canned | let g:Canned = {'foo': 'bar'}
call InsertExampleMultilineText('Dict')
normal \sUU

echomsg 'Test: Funcref'
unlet! g:Canned | let g:Canned = function('tr')
call InsertExampleMultilineText('Funcref')
normal \sUU

call vimtest#SaveOut()
call vimtest#Quit()
