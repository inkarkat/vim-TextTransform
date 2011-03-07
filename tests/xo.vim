function! DoXO(str)
    return substitute(a:str, 'x', 'o', 'g')
endfunction
function! DoOX(str)
    return substitute(a:str, 'o', 'x', 'g')
endfunction
call TextTransform#MapTransform('', '<Leader>sxo', 'DoXO')
call TextTransform#MapTransform('', '<Leader>sox', 'DoOX', ['i"', "i'", 'lines'])
