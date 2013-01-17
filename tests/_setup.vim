function! InsertExampleText( description, ... )
    call append(0, a:description)
    call append(1, '')

    for l:i in range(a:0 ? a:1 : 1)
	call append(1, "He said, <q>'In the 80's, Dan \"Duckling Dock\" Diestle won the world wrestling record' \"left-handed\".</q>")
    endfor
    normal! 2G03W
endfunction
function! InsertExampleMultilineText( description )
    call append(0, a:description)
    call append(1, 'he says: "the quick brown fox jumps')
    call append(2, "over the 'lazy dog'. \"No,")
    call append(3, 'please!" he yelled')
    call append(4, '')
    normal! 2G03W
endfunction

function! MarkBoundaries( text )
    return '[' . a:text . ']'
endfunction
function! MyTransform( text )
    " Converts alphabetic characters into "X", whitespace into "|" and the rest
    " into "?". Keeps newline characters. 
    return substitute(substitute(substitute(a:text, '\a', 'X', 'g'), '\n\@![^X \t]', '?', 'g'), '\s', '|', 'g')
endfunction
function! TheTransform( text )
    return substitute(a:text, '\<the\>', 'XXX', 'g')
endfunction
function! NoTransform( text )
    return a:text
endfunction
function! BadTransform( text )
    throw "This won't work"
endfunction
