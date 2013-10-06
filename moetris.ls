<- $
ALL <- $.get "https://www.moedict.tw/a/index.json" null, _, \text
ALL -= /[；，]/g
ALL -= /".",/g
window.ALL = ALL
match-cache = {}

keys = [
  90, 88, 67, 86, 66, 78, # zxcvbn
  65, 83, 68, 70, 71, 72, # asdfgh
  81, 87, 69, 82, 84, 89, # qwerty
  49, 50, 51, 52, 53, 54  # 123456
]
keyMap = {}
keys.forEach (keyCode, idx) ->
  x = ~~(idx % 6)
  y = ~~(idx / 6)
  keyMap[keyCode] =
    'false':
      'x': x
      'y': y
    'true':
      'x': x
      'y': y + 4

score = 0
ice = fire = time = 0

w = 2 + $ \#proto .width!
h = 2 + $ \#proto .height!
$('big').remove!
$.fx.interval = 50ms

$ document .on \keypress ({which}) -> $ \#wrap .click! if which is 32

cs = ''
select = ->
  c = it.text!
  if it.hasClass \active
    if ~(idx = cs.indexOf(c))
      it.removeClass "active red green"
      draw(cs.substring(0, idx) + cs.substring(idx + 1))
    return
  it.addClass \active
  cs += c
  draw cs
$ \body .on \click \.char ->
  select $ @
.on \keyup (e) -> if ~keys.indexOf(e.which)
  pos = keyMap[e.which]?[e.shiftKey]
  select($ '.char.col-' + pos.x .eq pos.y)

$ \.ice.button .click ->
  return if $ \body .hasClass \frozen
  return if ice <= 0; $ \#ice .text --ice
  $ \body .addClass \frozen
  $ \.falling .stop!
$ \.fire.button .click ->
  return if fire <= 0; $ \#fire .text --fire
  for c from 0 to 5
    xs = $ ".col-#c:not(.falling)" .get!
    xs.sort (a, b) -> $(b).css(\top) - $(a).css(\top)
    $(xs.0).remove!
  do-gravity!
$ \.time.button .click ->
  return if time <= 0; $ \#time .text --time
  return if $ \body .hasClass \paused
  $ \body .addClass \paused
  $ \.falling .stop!
  $ \#special .fadeOut duration: 10000ms, easting: \linear, complete: ->
    $ \#special .show!
    $ \body .removeClass \paused
    resume-falling!

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
$ \#proto .css { left: \5px, width: 10 + (6*w) + "px", height: h + "px", top: 20+9*h }
$ \#special .css { left: \5px, width: 10 + (6*w) + "px", height: h + "px", top: 25 }
$ \#wrap .css { width: \100% height: \100% } .click ->
  if $(@).hasClass \red
    $ \.active .removeClass \active .removeClass \red
    return draw ''
  if $(@).hasClass \green
    score += $(@).text!length
    $ \#score .text score
    $(@).removeClass \active .removeClass \green
    $ \#ice  .text <| ice += $ ".active .tint" .length
    $ \#fire .text <| fire += $ ".active .fire" .length
    $ \#time .text <| time += $ ".active .time" .length
    $(\.active).remove!
    do-gravity!
    draw ''
  else
    $ \.falling .finish!
  if $ \body .hasClass \frozen
    $ \body .removeClass \frozen
    resume-falling!

resume-falling = ->
  return if $ \body .hasClass \frozen
  return if $ \body .hasClass \paused
  $x = $ \.falling
  return doit! unless $x.length
  $x.animate { top: $x.data(\top) }, $x.data(\speed), \linear, ->
    $ \.falling .removeClass \falling
    do-gravity!; doit!

do-gravity = -> for c from 0 to 5
  xs = $ ".col-#c:not(.falling)" .get!
  xs.sort (a, b) -> $(b).css(\top) - $(a).css(\top)
  below = 0
  for x in xs
    below++
    top = 72 + (8 - below)*h
    continue if top == $(x).css \top
    $(x).animate { top }, 50ms, \linear

do doit = ->
  min = Infinity
  for c from 0 to 5
    cnt = $(".col-#c").length
    continue if min <= cnt
    min = cnt; col = c
  next = pick $(\big).text!
  special = <[ fire tint time ]>[Math.floor (Math.random! * 3)] if Math.random! < 0.1
  $x = $('<div/>' class: "ui char button large col-#col").append(
    $('<big/>').text(next).addClass(if next is \？ then \qq else if next is \＊ then \aa else \ww)
  ).append($('<i/>' class: "icon #special"))
  $x.css display: \inline-block position: \absolute left: col*w + 10
  $x.appendTo \body
  below = $ ".col-#col" .length
  if below > 8
    $ \.button .off \click
    return alert "Game over"
  $x.addClass \falling
  top = 72 + (8 - below)*h
  speed = (9 - below) * (100ms >? (500ms - score))
  $x.data { top, speed } .animate { top }, speed, \linear, ->
    $ \.falling .removeClass \falling
    do-gravity!; doit!

blacklist = {"": true}
function pick (cur='')
  return "一二三四五六七八九十"[Math.floor(Math.random! * 10)] unless cur is /[^＊？]/
  return "＊" if Math.random! < 0.05
  return "？" if Math.random! < 0.2
  seen = {}
  scores = []
  for c in (cur - /[＊？]/g)
    results = match-cache[c] ||= ALL.match(//[^"]*#c[^"]*//g)
    for r in results | r.length <= 8 and not blacklist[r]
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
