runtime plugin/SidTools.vim

silent! call TextTransform#Arbitrary#DoesNotExist()
let s:SID = Sid('autoload/TextTransform/Arbitrary.vim')
function! <SNR>{s:SID}_Error( onError, errorText )
    if a:onError ==# 'beep'
	echomsg 'beep:' g:teststep
    endif
endfunction
