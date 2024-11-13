call vimtest#AddDependency('vim-ingo-library')
if g:runVimTest =~# 'repeat\u'
    call vimtest#AddDependency('vim-repeat')
    call vimtest#AddDependency('vim-visualrepeat')
endif
call vimtest#AddDependency('vim-SidTools')  " for testing

function! InsertExampleText( description, ... )
    call append(0, a:description)
    call append(1, '')

    for l:i in range(a:0 ? a:1 : 1)
	call append(1, "He said, <q>'In the 80's, Dan \"Duckling Dock\" Diestle won the world wrestling record' \"left-handed\".</q>")
    endfor
    normal! 2G03W
endfunction
function! InsertExampleMultilineText( description )
    call append(0, a:description)
    call append(1, 'he says: "the quick brown fox jumps')
    call append(2, "over the 'lazy dog'. \"No,")
    call append(3, 'please!" he yelled')
    call append(4, '')
    normal! 2G03W
endfunction

function! MarkBoundaries( text )
    return '[' . a:text . ']'
endfunction
function! MyTransform( text )
    " Converts alphabetic characters into "X", whitespace into "|" and the rest
    " into "?". Keeps newline characters.
    return substitute(substitute(substitute(a:text, '\a', 'X', 'g'), '\n\@![^X \t]', '?', 'g'), '\s', '|', 'g')
endfunction
function! TheTransform( text )
    return substitute(a:text, '\<the\>', 'XXX', 'g')
endfunction
function! NoTransform( text )
    return a:text
endfunction
function! BadTransform( text )
    throw "This won't work"
endfunction
function! CannedTransform( text )
    return g:Canned
endfunction
function! ContextEcho( text )
    echomsg printf('mapMode %s, mode %s from %s to %s, triggered at %s', string(g:TextTransformContext.mapMode), strtrans(g:TextTransformContext.mode), string(g:TextTransformContext.startPos), string(g:TextTransformContext.endPos), string(g:TextTransformContext.triggerPos))
    return MarkBoundaries(a:text)
endfunction
function! GetContext()
    if type(g:context) == type([])
	let l:context = remove(g:context, 0)
	let l:context.description .= ' ('.len(g:context).')'
	if empty(g:context)
	    unlet g:context
	endif
    else
	let l:context = g:context
	unlet g:context
    endif
    return l:context
endfunction
function! ContextMockTransform( text )
    let l:context = GetContext()
    call vimtap#Is(g:TextTransformContext.mapMode,           l:context.mapMode,           l:context.description . ' - ' . 'mapMode')
    call vimtap#Is(g:TextTransformContext.mode,              l:context.mode,              l:context.description . ' - ' . 'mode')
    call vimtap#Is(g:TextTransformContext.startPos[2],       l:context.startPos,          l:context.description . ' - ' . 'startPos')
    call vimtap#Is(g:TextTransformContext.endPos[2],         l:context.endPos,            l:context.description . ' - ' . 'endPos')
    call vimtap#Is(g:TextTransformContext.arguments,         l:context.arguments,         l:context.description . ' - ' . 'arguments')
    call vimtap#Is(g:TextTransformContext.isBang,            l:context.isBang,            l:context.description . ' - ' . 'isBang')
    call vimtap#Is(g:TextTransformContext.register,          l:context.register,          l:context.description . ' - ' . 'register')
    call vimtap#Is(g:TextTransformContext.isAlgorithmRepeat, l:context.isAlgorithmRepeat, l:context.description . ' - ' . 'isAlgorithmRepeat')
    call vimtap#Is(g:TextTransformContext.isRepeat,          l:context.isRepeat,          l:context.description . ' - ' . 'isRepeat')

    return MyTransform(a:text)
endfunction
function! ContextArgumentsMockTransform( text )
    call vimtap#Is(g:TextTransformContext.arguments, g:context.arguments, g:context.description)
    return MyTransform(a:text)
endfunction
function! RegisterCheckTransform( text )
    let l:context = GetContext()
    call vimtap#Is(getreg(''), l:context.regContents, l:context.description . ' - register contents')
    call vimtap#Is(getregtype(''), l:context.regType, l:context.description . ' - register type')

    return MyTransform(a:text)
endfunction
