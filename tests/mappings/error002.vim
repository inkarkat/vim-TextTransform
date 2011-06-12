" Test error beep due to no transformation. 

call TextTransform#MakeMappings('', '<Leader>sU', 'NoTransform')
nmap <Plug>RingTheBell :<C-u>echomsg 'beep:' g:teststep<CR>


let g:teststep = 'single line'
call InsertExampleMultilineText(g:teststep)
normal \sUU

let g:teststep = 'visual characterwise selection'
call InsertExampleMultilineText(g:teststep)
normal v3e\sU


call vimtest#SaveOut()
call vimtest#Quit()
