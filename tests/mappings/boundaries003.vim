" Test boundaries of text object selection mode. 

call TextTransform#MakeMappings('', "<Leader>s'", 'MarkBoundaries', "i'")


function! Test( selection )
    let &selection = a:selection
    call InsertExampleText(a:selection . ' single text object')
    normal \s''
endfunction

call Test('inclusive')
call Test('exclusive')

call vimtest#SaveOut()
call vimtest#Quit()
