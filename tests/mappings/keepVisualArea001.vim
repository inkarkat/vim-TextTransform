" Test keeping a previous visual area.
" Tests that both the marks and the visual mode are kept after application of a
" linewise or motion mapping.

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')

call vimtest#StartTap()
call vimtap#Plan(18)

function! InsertExampleMultilineTextAndRecord( description )
    let s:description = a:description
    call InsertExampleMultilineText(a:description)
endfunction
function! IsSelection( when )
    call vimtap#Is(getpos("'<"), [0, 1, 2, 0], 'start of selection ' . a:when . ' ' . s:description)
    call vimtap#Is(getpos("'>"), [0, 1, 5, 0], 'start of selection ' . a:when . ' ' . s:description)
    call vimtap#Is(visualmode(), 'v', 'selection mode ' . a:when . ' ' . s:description)
endfunction

call InsertExampleMultilineTextAndRecord('single line')
execute "normal! 1G0lv3lgU\<C-o>"
call IsSelection('before')
normal \sUU
call IsSelection('after')

call InsertExampleMultilineTextAndRecord('character motion')
execute "normal! 1G0lv3lgU\<C-o>"
call IsSelection('before')
normal \sU3e
call IsSelection('after')

call InsertExampleMultilineTextAndRecord('line motion')
execute "normal! 1G0lv3lgU\<C-o>"
call IsSelection('before')
normal \sU+
call IsSelection('after')


call vimtest#Quit()
