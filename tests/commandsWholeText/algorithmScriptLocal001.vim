" Test script-local algorithm function with command. 

function! s:LocalAlgorithm( text )
    return '[' . a:text . ']'
endfunction
function! s:function(name)
    return function(substitute(a:name, '^s:', matchstr(expand('<sfile>'), '<SNR>\d\+_\zefunction$'),''))
endfunction 
call TextTransform#MakeCommand('', 'TransformIt', s:function('s:LocalAlgorithm'), { 'isProcessEntireText': 1 })


call InsertExampleMultilineText('single line')
normal! gg$
2TransformIt
normal! i#

call InsertExampleMultilineText('many lines')
normal! gg$
2,4TransformIt
normal! i#


call vimtest#SaveOut()
call vimtest#Quit()
