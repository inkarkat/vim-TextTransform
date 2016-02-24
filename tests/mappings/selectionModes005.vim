" Test custom function selection mode. 

" Though this test doesn't supply a count, the visual re-selection is off (it
" starts at the beginning of the line); this seems to be fixed by the same
" patch. 
call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

function! MySelect()
    execute 'normal! lv' . v:count1 . "l\<Esc>"
    return 1
endfunction
call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', function('MySelect'))


call InsertExampleMultilineText('single custom selection')
normal \sUU

call vimtest#SaveOut()
call vimtest#Quit()
