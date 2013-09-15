runtime plugin/SidTools.vim

let s:hookTarget = 'autoload/TextTransform/Arbitrary.vim'
execute 'runtime' s:hookTarget
let s:SID = Sid(s:hookTarget)
function! <SNR>{s:SID}_Error( onError, errorText )
    if a:onError ==# 'beep'
	echomsg 'beep:' g:teststep
    endif
endfunction
