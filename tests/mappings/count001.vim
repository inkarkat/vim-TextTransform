" Test count in operator-pending mapping. 

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')


call InsertExampleText('equivalence of count before motion and in motion', 2)
normal 05W\sU3E
normal j05W3\sUE

call InsertExampleText('count both before motion and in motion')
normal 05W3\sU2E


call vimtest#SaveOut()
call vimtest#Quit()
