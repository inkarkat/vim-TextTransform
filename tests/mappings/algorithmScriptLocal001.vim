" Test script-local algorithm function with mapping. 

function! s:LocalAlgorithm( text )
    return '[' . a:text . ']'
endfunction
function! s:function(name)
    return function(substitute(a:name, '^s:', matchstr(expand('<sfile>'), '<SNR>\d\+_\zefunction$'),''))
endfunction 
call TextTransform#MakeMappings('', '<Leader>sU', s:function('s:LocalAlgorithm'))


call InsertExampleMultilineText('single line')
normal \sUU

call InsertExampleMultilineText('character motion')
normal \sU3e

call InsertExampleMultilineText('line motion')
normal \sU+

call InsertExampleMultilineText('visual characterwise selection')
normal v3e\sU

call InsertExampleMultilineText('visual linewise selection')
normal Vj\sU

call InsertExampleMultilineText('visual blockwise selection')
execute "normal \<C-V>ej\\sU"


call vimtest#SaveOut()
call vimtest#Quit()
