" Test operator-pending mapping repetition with pure Vim features. 

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')


call InsertExampleText('character motion', 5)
normal \sU$
source helpers/repeat.vim

call InsertExampleText('character motion with text object', 5)
normal \sUi'
source helpers/repeat.vim


call vimtest#SaveOut()
call vimtest#Quit()
