<- $
ALL <- $.get "moetris.txt" null, _, \text
#ALL -= /[；，]/g
#ALL -= /".",/g
#ALL -= /"[^"]*[\uD800-\uDBFF][^"]*"/g
window.ALL = ALL
match-cache = {}

keys = [
  122, 120,  99, 118,  98, 110, # zxcvbn
   97, 115, 100, 102, 103, 104, # asdfgh
  113, 119, 101, 114, 116, 121, # qwerty
   49,  50,  51,  52,  53,  54, # 123456
   90,  88,  67,  86,  66,  78, # zxcvbn
   65,  83,  68,  70,  71,  72, # asdfgh
   81,  87,  69,  82,  84,  89, # qwerty
   33,  64,  35,  36,  37,  94  # !@#$%^
]
keyMap = {}
keys.forEach (keyCode, idx) ->
  keyMap[keyCode] =
    'key': String.fromCharCode keyCode
    'x': ~~(idx % 6)
    'y': ~~(idx / 6)

score = 0
ice = fire = time = 0

w = 75
h = 57
$('big').remove!

tap = if IsTouchDevice then \touchstart else \click
$ document .on \keypress ({which}) ->
  switch which
  | 105       => $ \.ice.button  .trigger tap
  | 111       => $ \.fire.button .trigger tap
  | 112       => $ \.time.button .trigger tap
  | 32        => $ \#wrap        .trigger tap
  | otherwise => if ~keys.indexOf(which)
    pos = keyMap[which]
    select($ ".char.col-#{pos.x}" .eq pos.y)

cs = ''
select = ->
  return if $ \body .hasClass \finished
  c = it.find \big .text!
  if it.hasClass \active
    if ~(idx = cs.lastIndexOf(c))
      it.removeClass "active red green"
      draw(cs.substring(0, idx) + cs.substring(idx + 1))
    return
  it.addClass \active
  cs += c
  draw cs

IsTouchDevice = \ontouchstart of window
             || \onmsgesturechange in window

if IsTouchDevice
  $ \body .addClass \touch
  $ \body .on \touchstart \.char -> select $ @
else
  $ \body .on tap, \.char -> select $ @

$ \.ice.button .on tap, ->
  return if $ \body .hasClass \frozen
  return if ice <= 0; $ \#ice .text --ice; $ \.ice.button .addClass \disabled unless ice
  $ \body .addClass \frozen
  $ \.falling .stop!
$ \.fire.button .on tap, ->
  return if fire <= 0; $ \#fire .text --fire; $ \.fire.button .addClass \disabled unless fire
  for c from 0 to 5
    xs = $ ".col-#c:not(.falling)" .get!
    xs.sort (a, b) -> $(b).css(\top) - $(a).css(\top)
    $(xs.0).detach!trigger \detached .remove!
  do-gravity!
$ \.time.button .on tap, ->
  return if time <= 0; $ \#time .text --time; $ \.time.button .addClass \disabled unless time
  return if $ \body .hasClass \paused
  $ \body .addClass \paused
  $ \.falling .stop!
  $ \#special .fadeOut duration: 10000ms, easting: \linear, complete: ->
    $ \#special .show!
    $ \body .removeClass \paused
    resume-falling!

draw = ->
  cs := it
  $ \#msg .text cs
  $ \#wrap .addClass \input
  return $ \#wrap .removeClass "active red green" unless cs.length
  $ \#wrap .addClass \active
  if ~ALL.index-of "\"#cs\""
    return $ \.active .removeClass \red .addClass \green
  if cs is /[＊？]/ and cs isnt /^[＊？]+$/ and ALL.match(//"(#{
    cs.replace(/？/g '[^"]').replace(/＊/g '(?:[^"]+)?')
  })"//)
    $ \#msg .text that.1
    $ \.active .removeClass \red .addClass \green
    return
  $ \.active .removeClass \green .addClass \red

$ \#top .css { left: \5px, width: (6*w) + "px", top: \5px }
$ \#proto .css { left: \5px, width: 10 + (6*w) + "px", height: h + "px", top: 20+9*h }
$ \#special .css { left: \5px, width: 10 + (6*w) + "px", height: h + "px", top: 25 }
$ \#msg .show!; $ \.icon.loading .remove!
$ \#wrap .removeClass \red .addClass \green .on tap, ->
  unless $ \body .hasClass \started
    $ \body .addClass \started
    $(@) .removeClass \green
    $ \#msg .text ''
    $ \#help .remove!
    doit!
    return
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
    $ \.ice.button  .removeClass \disabled if ice
    $ \.fire.button .removeClass \disabled if fire
    $ \.time.button .removeClass \disabled if time
    $(\.active).detach!trigger \detached .remove!
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

doit = ->
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
  $access = $('<div/>' class: 'access').text(
    keyMap[keys[col + (below - 1) * 6]]?.key
  )
  $x.append $access
  $x.on \detached, ->
    $chars = $ ".col-#col"
    $ ".col-#col > .access" .each (row, element) ->
      $ element .text keyMap[keys[col + row * 6]]?.key
  if below > 8
    $ \body .addClass \finished
    $ \.button .off tap .off \touchstart
    $ \#msg .text \再玩一次 .prepend $('<i/>' class: "icon repeat")
    $ \#wrap .addClass \secondary .on tap, ->
      window.location = document.URL.replace(/#.*$/, '')
    return
  $x.addClass \falling
  top = 72 + (8 - below)*h
  speed = (9 - below) * (100ms >? (500ms - score))
  $x.data { top, speed } .animate { top }, speed, \linear, ->
    $ \.falling .removeClass \falling
    do-gravity!; doit!

blacklist = {"": true}
function pick (cur='')
  # Freq list from: http://www.edu.tw/files/site_content/m0001/pin/biau1.htm
  return "萌的不一我是人有了大國來生在子們中上他時小地出以學可自這會成家到為天心年然要得說過個著能下動發臺麼車那行經去好開現就作後多方如事公看也長面力起裡高用業你因而分市於道外沒無同法前水電民對兒日之文當教新意情所實工全定美理頭本明氣進樣都主間老想重體山物知手相回性果政只此代和活親化加影什身己灣機部常見其正世"[Math.floor(Math.random! * 150)] unless cur is /[^＊？]/
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
  cands = []; until cands?length or !scores.length => cands = [ s for s in (scores.pop! ? '') / "\n" | not blacklist[s] ]
  while cands.length <= 5 and scores.length
    c2 = []; until c2?length or !scores.length => c2 = [ s for s in (scores.pop! ? '') / "\n" | not blacklist[s] ]
    cands ++= c2
  picks = ""
  for cand in cands
    for c in cur - /[＊？]/g => cand -= //#c//
    picks += cand
  return pick! unless picks
  return picks[Math.floor Math.random! * picks.length]
