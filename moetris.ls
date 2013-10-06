<- $
ALL <- $.get "https://www.moedict.tw/a/index.json" null, _, \text
ALL -= /[；，]/g
ALL -= /".",/g
window.ALL = ALL
match-cache = {}
console.log pick ''

score = 0

w = 2 + $ \#proto .width!
h = 2 + $ \#proto .height!
$('big').remove!
$.fx.interval = 50ms

$ document .on \keypress ({which}) -> $ \#wrap .click! if which is 32

cs = ''
$ \body .on \click \.char ->
  c = $(@).text!
  if $(@).hasClass \active
    if (idx = cs.indexOf c) isnt -1
      $(@).removeClass "active red green"
      draw cs.substring(0, idx) + cs.substring(idx + 1)
    return
  $(@).addClass \active
  draw(cs += c)

draw = ->
  cs := it
  $ \#wrap .text cs
  return $ \#wrap .removeClass "active red green" unless cs.length
  $ \#wrap .addClass \active
  if ~ALL.index-of "\"#cs\""
    return $ \.active .removeClass \red .addClass \green
  if cs is /[＊？]/ and cs isnt /^[＊？]+$/ and ALL.match(//"(#{
    cs.replace(/？/g '[^"]').replace(/＊/g '(?:[^"]+)?')
  })"//)
    $ \#wrap .text that.1
    $ \.active .removeClass \red .addClass \green
    return
  $ \.active .removeClass \green .addClass \red

$ \#top .css { left: \5px, width: (6*w) + "px", top: \5px }
$ \#proto .css { left: \5px, width: 10 + (6*w) + "px", height: h + "px", top: 9*h }
$ \#wrap .css { width: \100% height: \100% } .click ->
  if $(@).hasClass \red
    $ \.active .removeClass \active .removeClass \red
    return draw ''
  if $(@).hasClass \green
    score += $(@).text!length
    $ \#score .text score
    $(@).removeClass \active .removeClass \green
    $(\.active).remove!
    do-gravity!
    return draw ''
  $ \.falling .finish!

do-gravity = -> for c from 0 to 5
  xs = $ ".col-#c:not(.falling)" .get!
  xs.sort (a, b) -> $(b).css(\top) - $(a).css(\top)
  below = 0
  for x in xs
    below++
    top = 50 + (8 - below)*h
    continue if top == $(x).css \top
    $(x).animate { top }, 250ms, \linear

do doit = ->
  min = Infinity
  for c from 0 to 5
    cnt = $(".col-#c").length
    continue if min <= cnt
    min = cnt; col = c
  next = pick $(\big).text!
  $x = $('<div/>' class: "ui char button large col-#col").append(
    $('<big/>').text(next).addClass(if next is \？ then \qq else if next is \＊ then \aa else \ww)
  ).append($('<small/>').text())
  $x.css display: \inline-block position: \absolute left: col*w + 10
  $x.appendTo \body
  below = $ ".col-#col" .length
  return alert "Game over"  if below > 8
  $x.addClass \falling
  $x.animate { top: 50 + (8 - below)*h }, (9 - below)*(100ms >? (500ms - score)), \linear, ->
    $ \.falling .removeClass \falling
    do-gravity!; doit!

function pick (cur='')
  return "一二三四五六七八九十"[Math.floor(Math.random! * 10)] unless cur is /[^＊？]/
  return "＊" if Math.random! < 0.05
  return "？" if Math.random! < 0.2
  seen = {}
  scores = []
  blacklist = {"": true}
  for c in (cur - /[＊？]/g)
    results = match-cache[c] ||= ALL.match(//[^"]*#c[^"]*//g)
    for r in results | r.length <= 8
      seen[r] ?= 0; score = ++seen[r]
      if r.length > (score + 1) => scores[score] ?= ""; scores[score] += "#r\n"
      else blacklist[r] = true
  cands = []; until cands?length => cands = [ s for s in (scores.pop! ? '') / "\n" | not blacklist[s] ]
  while cands.length <= 5 and scores.length
    c2 = []; until c2?length or !scores.length => c2 = [ s for s in (scores.pop! ? '') / "\n" | not blacklist[s] ]
    cands ++= c2
  picks = ""
  for cand in cands
    for c in cur - /[＊？]/g => cand -= //#c//
    picks += cand
  return picks[Math.floor Math.random! * picks.length]
