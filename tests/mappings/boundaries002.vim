" Test boundaries of built-in selection modes. 

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

call TextTransform#MakeMappings('', '<Leader>s<Bar>', 'MarkBoundaries')

function! Test( selection )
    let &selection = a:selection
    call InsertExampleMultilineText(a:selection . ' multiple lines')
    normal 2\s||
endfunction

call Test('inclusive')
call Test('exclusive')

call vimtest#SaveOut()
call vimtest#Quit()
