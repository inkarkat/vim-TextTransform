" Test boundaries of built-in selection modes. 

call TextTransform#MakeMappings('', '<Leader>s<Bar>', 'MarkBoundaries')

function! Test( selection )
    let &selection = a:selection

    call InsertExampleMultilineText(a:selection . ' single line')
    normal \s||

    call InsertExampleMultilineText(a:selection . ' character motion')
    normal \s|3e

    call InsertExampleMultilineText(a:selection . ' line motion')
    normal \s|+

    call InsertExampleMultilineText(a:selection . ' visual characterwise selection')
    normal v3e\s|

    call InsertExampleMultilineText(a:selection . ' visual linewise selection')
    normal Vj\s|

    call InsertExampleMultilineText(a:selection . ' visual blockwise selection')
    execute "normal \<C-V>ej\\s|"
endfunction

call Test('inclusive')
call Test('exclusive')

call vimtest#SaveOut()
call vimtest#Quit()
