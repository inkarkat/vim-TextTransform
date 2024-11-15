TEXT TRANSFORM
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin allows you to build your own text transformations. You only supply
the transformation algorithm in the form of a Vim function that takes a string
and returns the transformed text (think substitute()), and TextTransform
will create all appropriate mappings and / or commands with a single call!

Do you often perform the same :substitute commands over and over again? You
may be able to save yourself a lot of typing by creating custom commands and
mappings for it. Because the mappings (like built-in Vim commands such as gU
or g?)  are applicable to text moved over by {motion}, entire lines, and the
visual selection, you'll also have way more flexibility and places where you
can apply them (compared to the line-based range of :substitute).

### RELATED WORKS

- Idea, design and implementation are based on Tim Pope's unimpaired.vim
  plugin ([vimscript #1590](http://www.vim.org/scripts/script.php?script_id=1590)). It implements XML, URL and C String encoding
  mappings, but isn't extensible with other algorithms.
  The TextTransform plugin enhances unimpaired's transformation function with
  handling of text objects and a list of selection fallbacks, and allows to
  not only create mappings, but also transformation commands.
- vim-transform (https://github.com/t9md/vim-transform) pipes the selection
  through (multiple, configurable) external commands.

USAGE
------------------------------------------------------------------------------

    TextTransform#MakeMappings( {mapArgs}, {key}, {algorithm} [, {selectionModes}] )

                            Create normal and visual mode mappings that apply
                            {algorithm} to the text covered by {motion}, [count]
                            line(s), and the visual selection.

                            When {key} is <Leader>xy, the following mappings will
                            be created:
                            - <Leader>xy{motion}    applies to moved-over text
                            - <Leader>xyy           applies to entire current line
                            - {Visual}<Leader>xy    applies to visual selection
                            For the linewise normal mode mapping, the last
                            character of {key} is doubled, as is customary in Vim.

                            When {key} is empty, only <Plug> mappings are created;
                            mappings are also skipped when there are existing
                            mappings to the <Plug> mappings. When {algorithm} is
                            "MyTransform", the following <Plug> mappings are
                            generated:
                                nmap <Plug>TextTMyTransformOperator
                                nmap <Plug>TextTMyTransformLine
                                vmap <Plug>TextTMyTransformVisual
                            Use this to selectively override or disable individual
                            mappings.

                            :map-arguments can be passed in {mapArgs}, e.g.
                            "<buffer>" to make the generated mappings
                            buffer-local.

                            {algorithm} is the name of a function: "MyTransform",
                            or a Funcref: function("MyTransform"). This function
                            must take one string argument and return a string.
                                function MyTransform( text )
                                    return '[' . toupper(a:text) . ']'
                                endfunction
                            When the text that the mapping applies to spans more
                            than one line, {algorithm} is invoked only once with
                            the entire, newline-delimited text. You need to
                            consider that when using regular expression atoms like
                            ^ and $.
                            If the algorithm needs to inspect the place in the
                            buffer from where the text was retrieved, this
                            information is provided in g:TextTransformContext, a
                            dictionary with the following keys:
                                "mapMode":  indicates what triggered the
                                            transformation, one of
                                            "n": normal mode mapping for line(s)
                                                 e.g. <Leader>xyy
                                            "o": operator pending mode mapping for
                                                 moved-over text
                                                 e.g. <Leader>xy{motion}
                                            "v": visual mode mapping
                                                 e.g. {Visual}<Leader>xy
                                            "c": custom Ex command
                                "mode": indicates the selection mode, one of "v",
                                        "V", or "^V" (like visualmode())
                                "startPos": the start position of the text
                                "endPos"  : the end position of the text
                                "triggerPos":
                                            the cursor position where the
                                            transformation has been triggered
                                "arguments":List of optional passed command
                                            arguments (when arguments have been
                                            configured for a command; always empty
                                            for mappings).
                                "isBang":   Flag whether a [!] was passed to the
                                            command; always 0 for mappings.
                                "register": Used register (as v:register has
                                            been clobbered). Commands need to pass
                                            :command-register in
                                            {commandOptions} to fill this.
                                "isAlgorithmRepeat":
                                            Flag whether the same
                                            TextTransform-algorithm is used
                                            (either through another mapping /
                                            command invocation, or via a mapping
                                            repeat .) as the last time.
                                "isRepeat": Flag whether the last used mapping
                                            with the same algorithm has been
                                            repeated via the . command. For
                                            commands that process each line
                                            individually, is 1 on subsequently
                                            processed lines after the first line.

                            The function can :throw an exception to signal an
                            error. When the original text is returned,
                            TextTransform will print an error that nothing was
                            transformed. Do this when the transformation is not
                            applicable.

                            By default, the <Leader>xyy mapping will be applied to
                            the entire line. For some transformations, a different
                            default scope may make more sense, like the text
                            between quotes. After all, the <Leader>xyy mapping is
                            often faster than <Leader>xy{motion} or first doing a
                            visual selection, and is easiest to commit to muscle
                            memory, so it should "do what I mean".

                            The optional {selectionModes} argument is one of:
                            - a single text object (such as "aw")
                            - motion (e.g. "$")
                            - Funcref (for a custom selection)
                            - /-delimited "/{pattern}/" (which selects the text
                              region under / after the cursor that matches
                              {pattern})
                            - List of
                              [{begin-pattern}, {end-pattern}[, {match}[, {index}]]]
                              or
                              [[{begin-pattern}, {offset}],
                               [{end-pattern}, {offset}]
                               [, {match}[, {index}]]]
                              which select [[{index}'d occurrence of] the
                              {match}ed text inside] / full lines around the
                              current position
                            - the string "lines", which represents the default
                              behavior
                            If you pass a list of these, TextTransform tries each
                            selectionMode, one after the other, until one captures
                            non-empty text. For example, the passed list ['i"',
                            "i'", "lines"] will cause TextTransform to first try
                            to capture the text inside double quotes, then fall
                            back to text inside single quotes when the first one
                            doesn't yield any text. Finally, the "lines" will
                            transform the entire line if the single quote capture
                            failed, too.
                            A custom function should create a visual selection and
                            return a non-zero value if the selection can be made.
                            (Otherwise, the next selectionMode in the list is
                            tried.) Here's a senseless example which selects
                            [count] characters to the right of the cursor:
                                function! MySelect()
                                    execute 'normal! lv' . v:count1 . "l\<Esc>"
                                    return 1
                                endfunction

    TextTransform#MakeCommand( {commandOptions}, {commandName}, {algorithm} [, {options}] )

                            Create a custom command {commandName} that takes a
                            range (defaulting to the current line), and applies
                            {algorithm} to the line(s). With an optional [!], the
                            usual "Nothing transformed" error is suppressed.

                            :command attributes can be passed in
                            {commandOptions}. For example, pass "-range=%" to make
                            the command apply to the entire buffer when no range
                            is specified. You can pass "-nargs=..." to pass
                            arguments to the algorithm (via
                            g:TextTransformContext.arguments).

                            {algorithm} is the name of a function or a Funcref,
                            cp. Transform-algorithm.

                            The optional {options} dictionary can contain the
                            following keys:
        isProcessEntireText Flag whether all lines are passed as one
                            newline-delimited string to {algorithm}, like mappings
                            from TextTransform#MakeMappings() do. Off by
                            default, so that each line is passed to {algorithm}
                            individually (without the newline). This allows for a
                            more efficient transformation. For subsequent lines,
                            g:TextTransformContext.isRepeat is set to 1.
                            You need to enable this if {algorithm} transforms the
                            newline, adds or removes lines.

    TextTransform#MakeSelectionCommand( {commandOptions}, {commandName}, {algorithm}, {selectionModes} )

                            Create a custom command {commandName} that applies
                            {algorithm} on the TextTransform-selectionModes
                            specified by {selectionModes}, or the current visual
                            selection (when invoked from visual mode).
                            This is useful for algorithms that do not make sense
                            on entire lines. It's the command-variant of the
                            line-based mapping created by
                            TextTransform#MakeMappings(). For seldomly used
                            transformations, a command may have advantages over a
                            mapping: It doesn't take up precious mapping keys and
                            is more explorable via command-line completion.

                            Rest of the arguments as with TextTransform#MakeCommand().

### EXAMPLE

Here's a stupid transformation function that replaces all alphabetic
characters with "X":

    function! BlankOut( text )
        return substitute(a:text, '\a', 'X', 'g')
    endfunction

With this, this single call:

    call TextTransform#MakeMappings('', '<Leader>x', 'BlankOut')

creates this set of mappings:

    <Leader>x{motion}   transforms the text covered by {motion}
    <Leader>xx          transforms [count] line(s)
    {Visual}<Leader>x   transforms the visual selection

You can set up a command for this transformation just as easily:

    call TextTransform#MakeCommand('', 'TextBlankOut', 'BlankOut')

so you can blank out the next three lines via

    :.,.+2TextBlankOut

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-TextTransform
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim TextTransform*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.042 or
  higher.
- repeat.vim ([vimscript #2136](http://www.vim.org/scripts/script.php?script_id=2136)) plugin (optional)
- visualrepeat.vim ([vimscript #3848](http://www.vim.org/scripts/script.php?script_id=3848)) plugin (optional)

IDEAS
------------------------------------------------------------------------------

- Provide a :[range]TextTransform {commandName1} [{commandName2} ...] with
  custom completion of defined commands that applies all transformations to
  the same [range]. Suggested by Zhao Cai.
- Offer utility functions to split the text according to the used syntax
  groups (through g:TextTransformContext and synID()), to simplify selective
  application in algorithms. Suggested by Zhao Cai.

### CONTRIBUTING

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-TextTransform/issues or email (address below).

HISTORY
------------------------------------------------------------------------------

##### 1.30    13-Nov-2024
- ENH: Add range selectionMode that covers full lines between two patterns
  around the cursor, optionally with offsets, optionally just a match inside
  that range, optionally one indexed match.
- ENH: Add g:TextTransformContext.triggerPos.
- Mappings created through TextTransform#MakeMappings() now also abort on
  error.
- BUG: Correctly double special keys with non-alpha characters (like &lt;C-]&gt;).

__You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.042!__

##### 1.25    29-Mar-2019
- Minor: Remove debugging output when a command transforms whole lines.
- FIX: Correctly handle command range of :. when on a closed fold. Need to use
  ingo#range#NetStart().
- The selectionModes argument may (in /{pattern}/ form) contain special
  characters (e.g. "|" in /foo\\|bar/) that need escaping in order to survive.
- Add TextTransform#Selections#EntireBuffer() utility text selection.
- FIX: Redefinition of l:SelectionModes inside loop (since 1.12) may cause
  "E705: Variable name conflicts with existing function" (in Vim 7.2.000).
  Move the variable definition out of the loop.
- Don't apply TextTransform#Selections#SurroundedByCharsInSingleLine() when
  [count] is given; skip to the next selectionMode then.
- Handle non-String results returned by the algorithm via
  TextTransform#ToText().
- When transforming individual lines and we get multiple lines as the
  algorithm's result, setline() cannot be used; instead, use
  ingo#lines#Replace().
- When transforming individual or whole lines and we get multiple / additional
  lines as the algorithm's result, these need to be accounted for, for cursor
  positioning and reporting.
- Add TextTransform#ToText() to handle non-String results returned by the
  algorithm. Floats need to be explicitly converted; Lists should be
  flattened, too, to yield correct results for the modification check with the
  original text. Dicts and Funcrefs should not be returned and cause an
  exception.
- Pass v:count, not v:count1 to (visual)repeat.vim; this matters when using
  TextTransform#Selections#SurroundedByCharsInSingleLine(), which doesn't
  handle a count.
- FIX: Do not attempt to restore empty visual mode, as this results in a beep;
  this can happen when no visual selection wasn't done yet.
- ENH: Add g:TextTransformContext.register for transformations that use a
  (user-specified) register.
- ENH: Keep the original register contents of the default register (that is
  used for buffer manipulation) during application of the algorithm. The user
  may want to access it.

__You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.022!__

##### 1.24    19-Jun-2014
- ENH: Allow optional [!] for made commands, and suppress the "Nothing
  transformed" error in that case. This can help when using the resulting
  command as an optional step, as prefixing with :silent! can be difficult to
  combine with ranges, and would suppress _all_ transformation errors.
- ENH: Add g:TextTransformContext.isBang (for custom transformation commands).

##### 1.23    31-May-2014
- ENH: Support selection mode "/{pattern}/", which selects the text region
  under / after the cursor that matches {pattern}.
- Minor: Also handle :echoerr in the algorithm.

##### 1.22    06-Mar-2014
- Add TextTransform/Selections.vim.

##### 1.21    15-Jan-2014
- Minor: Use functions for newer ingo-library.
- Need to use ingo#compat#setpos() to restore the selection in Vim versions
  before 7.3.590.

__You need to update to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)) version 1.015!__

##### 1.20    25-Sep-2013
- Minor: Make substitute() robust against 'ignorecase'.
- FIX: When the selection mode is a text object, and the text is at the end of
  the line, the replacement is inserted one-off to the left.
- Implement abort on error for generated commands.
- Add g:TextTransformContext.mapMode context information so that
  transformations can query from which source (line- or motion-mapping, or
  custom command) they've been triggered.
- Add g:TextTransformContext.isAlgorithmRepeat and
  g:TextTransformContext.isRepeat context information (the latter through
  additional &lt;Plug&gt;TextR... mappings) so that transformations that e.g. query
  the user for something can skip the query and re-use the previously entered
  value on a repeat of the mapping. It also allows commands that process the
  lines individually to do different processing (or caching of expensive
  values) for the first processed line.
- Allow to pass command arguments, which are then accessible to the algorithm
  through g:TextTransformContext.arguments.

##### 1.11    17-May-2013
- Avoid changing the jumplist.
- Add dependency to ingo-library ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)).
- FIX: When the selection mode is a text object, must still establish a visual
  selection of the yanked text so that g:TextTransformContext contains valid
  data for use by a:algorithm.

##### 1.10    19-Jan-2013
- FIX: In a blockwise visual selection with $ to the end of the lines, only
  the square block from '&lt; to '&gt; is transformed. Need to yank the selection
  with gvy instead of defining a new selection with the marks, a mistake
  inherited from the original unimpaired.vim implementation.
- Save and restore the original visual area to avoid clobbering the '&lt; and '&gt;
  marks and gv by line- and motion mappings.
- Temporarily set g:TextTransformContext to the begin and end of the currently
  transformed area to offer an extended interface to algorithms.

##### 1.03    05-Sep-2012
- For the custom operators, handle readonly and nomodifiable buffers by
  printing just the warning / error, without the multi-line function error.
- Avoid clobbering the expression register (for commands that use
  options.isProcessEntireText).

##### 1.02    28-Jul-2012
- Avoid "E706: Variable type mismatch" when TextTransform#Arbitrary#Expression()
is used with both Funcref- and String-type algorithms.

##### 1.01    05-Apr-2012
- In mappings and selection commands, place the cursor at the beginning of the
transformed text, to be consistent with built-in transformation commands like
gU, and because it makes much more sense.

##### 1.00    05-Apr-2012
- First published version.

##### 0.01    07-Mar-2011
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2011-2024 Ingo Karkat -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
