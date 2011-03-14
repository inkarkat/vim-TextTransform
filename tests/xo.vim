function! DoXO(str)
    return substitute(a:str, 'x', 'o', 'g')
endfunction
function! DoOX(str)
    return substitute(a:str, 'o', 'x', 'g')
endfunction
call TextTransform#MapTransform('', '<Leader>sxo', 'DoXO')
call TextTransform#MapTransform('', '<Leader>sox', 'DoOX', ['i"', "i'", 'lines'])

function! MySelect()
    execute "normal! F\"vf\"\<Esc>"
    return 1
endfunction
call TextTransform#MapTransform('', '<Leader>soy', 'DoOX', function('MySelect'))

call TextTransform#MapTransform('', '<Leader>soz', 'DoOX', [function('TextTransformSelections#QuotedInSingleLine'), 'lines'])
