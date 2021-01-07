func! box#On()
  set ve=all
endfunc

func! box#Up()
  let curpos = getcurpos()
  if curpos[1] == 1
    put!=''
    call setpos(".", curpos)
  else
    norm! k
  endif
endfunc

func! box#Down() abort
  let curpos = getcurpos()
  if curpos[1] == line('$')
    put=''
    let curpos[1] = curpos[1] + 1
    call setpos(".", curpos)
  else 
    norm! j
  endif
endfunc

func! box#GetPos(mark) 
  let pos = getpos(a:mark)
  let result = [pos[1], virtcol(a:mark)]
  return result
endfunc

func! box#GetBounds() abort
  let startpos = box#GetPos("'<")
  let endpos = box#GetPos("'>")
  let numlines = abs(endpos[0] - startpos[0])
  let startline = min([startpos[0], endpos[0]]) 
  let numcols = abs(endpos[1] - startpos[1])
  let startcol = min([startpos[1], endpos[1]])
  let endcol = startcol + numcols
  let endline = startline + numlines
  return {
        \'startpos': startpos,
        \'endpos': endpos,
        \'startline': startline,
        \'numlines': numlines,
        \'startcol': startcol,
        \'numcols': numcols,
        \'endcol': endcol,
        \'endline': endline
        \}
endfunc

let s:boxchars  = ['│',  '─',  '┌',  '┐',  '└',  '┘',  '┼',  '├',  '┤',  '┬',  '┴']
let s:boxgraphs = ['vv', 'hh', 'dr', 'dl', 'ur', 'ul', 'vh', 'vr', 'vl', 'dh', 'uh']
" vh + __ = vh
" v_ + _h = vh
" v_ + _r = vr
" v_ + _l = vl
" d_ + _h = dh
" u_ + _h = uh

" _r + _l = _h 
" d_ + u_ = v_

func! box#MixGraphs(graph1, graph2) abort
  let di_1 = a:graph1[0]
  let di_2 = a:graph2[1]

  if a:graph1[0] == 'd' && a:graph2[0] == 'u'
    let di_1 = 'v'
  elseif a:graph2[0] == 'd' && a:graph1[0] == 'u'
    let di_1 = 'v'
  elseif a:graph1[0] == 'v' && a:graph2[0] == 'u'
    let di_1 = 'v'
  elseif a:graph1[0] == 'v' && a:graph2[0] == 'd'
    let di_1 = 'v'
  endif

  if a:graph1[1] == 'r' && a:graph2[1] == 'l'
    let di_2 = 'h'
  elseif a:graph2[1] == 'r' && a:graph1[1] == 'l'
    let di_2 = 'h'
  elseif a:graph1[1] == 'h' && a:graph2[1] == 'r'
    let di_2 = 'h'
  elseif a:graph1[1] == 'h' && a:graph2[1] == 'l'
    let di_2 = 'h'
  endif

  if a:graph1 == 'vh'
    return 'vh'
  elseif di_1 == 'v' && di_2 == 'h'
    return 'vh'
  elseif di_1 == 'v' && di_2 == 'r'
    return 'vr'
  elseif di_1 == 'v' && di_2 == 'l'
    return 'vl'
  elseif di_1 == 'd' && di_2 == 'h'
    return 'dh'
  elseif di_1 == 'u' && di_2 == 'h'
    return 'uh'
  endif
endfunc

func! box#GetChar(existing_char, new_char, adding) abort
  let existing_ind = index(s:boxchars, a:existing_char)

  if existing_ind == -1
    return a:new_char
  else
    let existing_graph = s:boxgraphs[existing_ind]
    let new_ind = index(s:boxchars, a:new_char)
    let new_graph = s:boxgraphs[new_ind] 

    let combo_graph = box#MixGraphs(existing_graph, new_graph)
    let combo_ind = index(s:boxgraphs, combo_graph)
    if combo_ind != -1
      return s:boxchars[combo_ind]
    else
      " attempt to mix the other way around
      let combo_graph = box#MixGraphs(new_graph, existing_graph)
      let combo_ind = index(s:boxgraphs, combo_graph)
      if combo_ind != -1
        return s:boxchars[combo_ind]
      else
        return a:new_char
      endif
    endif
  endif
endfunc

func! box#Draw() abort
  let bounds = box#GetBounds()
  let startpos = bounds['startpos']
  let endpos = bounds['endpos']
  let numlines = bounds['numlines'] 
  let startline = bounds['startline'] 
  let numcols = bounds['numcols']
  let startcol = bounds['startcol'] 
  let endcol = bounds['endcol']

  let ind_v = 0
  for line in range(startline, startline + numlines)
    let ind_h = 0
    let line_text_list = split(getline(line), '\zs')
    let len = len(line_text_list)
    if len < endcol 
      for i in range (len, endcol)
        call add(line_text_list, ' ')
      endfor
    endif
    for col in range(startcol, endcol)
      let curr_char = line_text_list[col - 1]
      if ind_v == 0
        if ind_h == 0
          let line_text_list[col - 1] = box#GetChar(curr_char, s:boxchars[2], 1)
        elseif ind_h == numcols
          let line_text_list[col - 1] = box#GetChar(curr_char, s:boxchars[3], 1)
        else
          let line_text_list[col - 1] = box#GetChar(curr_char, s:boxchars[1], 1)
        endif
      elseif ind_v == numlines
        if ind_h == 0
          let line_text_list[col - 1] = box#GetChar(curr_char, s:boxchars[4], 1)
        elseif ind_h == numcols
          let line_text_list[col - 1] = box#GetChar(curr_char, s:boxchars[5], 1)
        else
          let line_text_list[col - 1] = box#GetChar(curr_char, s:boxchars[1], 1)
        endif
      else
        if ind_h == 0 || ind_h == numcols
          let line_text_list[col - 1] = box#GetChar(curr_char, s:boxchars[0], 1)
        endif
      endif

      let ind_h += 1
    endfor
    call setline(line, join(line_text_list, ''))
    let ind_v += 1
  endfor

endfunc
