" Test error message due to no transformation. 

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'NoTransform', 'lines')


let g:teststep = 'single line'
call InsertExampleMultilineText(g:teststep)
echomsg g:teststep
TransformIt

let g:teststep = 'visual characterwise selection'
call InsertExampleMultilineText(g:teststep)
echomsg g:teststep
execute "normal! v3e:TransformIt\<CR>"


call vimtest#SaveOut()
call vimtest#Quit()
