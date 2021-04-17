" markdown_bujo.vim - A minimalist todo list manager
" Maintainer:   Jersey Fonseca <http://www.jerseyfonseca.com/>
" Version:      0.5

" The following check/uncheck script from https://gist.github.com/olmokramer/feadbf14a055efd46a8e1bf1e4be4447

let s:bullet = '^\s*\%(\d\+\.\|[-+*]\)'

function! markdown_bujo#checkbox#toggle(...) abort
    let c = a:0 ? a:1 : toupper(escape(nr2char(getchar()), '\.*'))

    if c !~ '\p'
        return
    endif

    call search(s:bullet, 'bcW')

    for i in range(v:count1)
        try
            execute 'keeppatterns s/' . s:bullet . '\s\+\[\zs.\ze\]/\=submatch(0) == c ? " " : c/'
        catch /E486/
            execute 'keeppatterns s/' . s:bullet . '\s\zs/[' . c . '] /'
        endtry

        if i < v:count1 - 1 && !search(s:bullet, 'W')
            break
        endif
    endfor

    if exists('*repeat#set')
        call repeat#set(":\<C-u>call markdown_bujo#checkbox#toggle('" . c . "')\<CR>")
    endif
endfunction

function! markdown_bujo#checkbox#remove() abort
    call search(s:bullet, 'bcW')

    try
        for i in range(v:count1)
            execute 'keeppatterns s/' . s:bullet . '\s\zs\s*\[.\] //'

            if i < v:count1 - 1 && !search(s:bullet, 'W')
                break
            endif
        endfor
    catch /E486/
        " No checkbox found.
    endtry

    if exists('*repeat#set')
        call repeat#set(":\<C-u>call markdown_bujo#checkbox#remove()\<CR>")
    endif
endfunction

" My mappings and settings, should probably live in .vimrc but
" adding here to document them
" works as toggle and to add initial checkbox too
noremap <silent> <leader>to :call markdown_bujo#checkbox#toggle('x')<CR>
" started
noremap <silent> <leader>ts :call markdown_bujo#checkbox#toggle('/')<CR>

" make it fit nicely in thin window
setlocal wrap 
setlocal linebreak
setlocal breakindent
setlocal breakindentopt=sbr
setlocal showbreak=>>>
setlocal conceallevel=2
setlocal concealcursor=nc

" Abbreviations that expand when you hit space
" local to the buffer
:iabbrev <buffer> started - [/]
:iabbrev <buffer> todo - [.]
:iabbrev <buffer> done - [x]

" fancy unicode bullet points (saves horizontal space too)
" though it confuses the cursorcolumn,I might need to switch
" that off or a find a different way.
syntax match Bujo '\v[-+*] \[ \]' conceal cchar=•
syntax match Bujo '\c\v[-+*] \[x\]' conceal cchar=✕
syntax match Bujo '\v[-+*] \[\/\]' conceal cchar=⟋
