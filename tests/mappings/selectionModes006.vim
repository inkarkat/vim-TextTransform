" Test custom function selection mode. 

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

function! MySelect()
    execute 'normal! lv' . v:count1 . "l\<Esc>"
    return 1
endfunction
call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', function('MySelect'))


call InsertExampleMultilineText('multiple text object')
normal 3\sUU


call vimtest#SaveOut()
call vimtest#Quit()
