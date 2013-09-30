<- $
score = 0
key = ''
record = ''
items = []
$ \.hidden .hide!

MAX = 10

$ \#quit .click ->
  $ \.log-line:last .remove!
  $ \#main .fadeOut -> $ \#again .show!
$ \#next .click ->
  score++
  reason = $ \#reason .val! .replace(/[\n,]/g \，)
  choice = $ \.choice.green .attr \id
  row = "#key,#choice,#reason\n"
  switch choice
  | \x => $(\.log-x:last).addClass \positive; $(\.log-y:last).addClass \negative
  | \y => $(\.log-x:last).addClass \negative; $(\.log-y:last).addClass \positive
  | \z => $(\.log-x:last).addClass \warning; $(\.log-y:last).addClass \warning
  | \w => $(\.log-x:last).addClass \active; $(\.log-y:last).addClass \active
  window.total++ unless choice is \w
  refresh-total!
  $ \.log-reason:last .text reason
  $.ajax({ dataType: 'jsonp', url: "https://www.moedict.tw/dodo/log/?log=#{ encodeURIComponent row }" })
  record += row
  $ \#progress-text .text "#score / #MAX"
  $ \#progress-bar .css \width "#{ score / MAX * 100 }%"
  if score >= MAX
    $ \#main .fadeOut -> $ \#again .show!
    return
  refresh!

LoadedScripts = {}
function getScript (src, cb)
  return cb! if LoadedScripts[src]
  LoadedScripts[src] = true
  $.ajax do
    type: \GET
    url: src
    dataType: \script
    cache: yes
    crossDomain: yes
    complete: cb

window.restart = restart = (idx='') ->
  window.location = document.URL.replace(/#.*$/, idx)

window.grok-hash = grok-hash = ->
  if location.hash is /^#(\d+)/
    refresh RegExp.$1
    return true
  return false

window.seen = {}
window.total = 0
getScript \data.js ->
  items := window.dodo-data
  refresh! unless grok-hash!
  $.get \https://www.moedict.tw/dodo/log.txt (data) ->
    window.seen = data
    for line in data.split(/[\r\n]/) | line is /^([^,]+,[^,]+),([wxyz])/
      key = RegExp.$1
      val = RegExp.$2
      if window.seen[key]
        window.seen[key] += val
      else
        window.seen[key] = val
      window.total++ if val is /[xyz]/
    refresh-total!

refresh-total = window.refresh-total = ->
  percent = Math.floor(window.total / items.length * 100)
  $ \#total-text .text "目前進度：#{window.total} / #{ items.length } (#percent%)"
  $ \#total-bar .css \width "#percent%"

function pick-item (idx)
  idx ||= Math.floor(Math.random! * items.length)
  result = try items[+idx]
  return pick-item! unless result
  items[idx] = null
  hash = "##idx"
  if location.hash is /^#(\d+)/ and "#{location.hash}" isnt hash
    try history.pushState null, null, hash
      catch => location.replace hash
  return "#result\n#idx"

function refresh (fixed-idx)
  [book, x-key, x, y-key, y, idx] = pick-item(fixed-idx)  / '\n'
  key := "#x-key,#y-key"
  if not fixed-idx and prior = window.seen[key]
    # Reroll with 90% certainty if it's judged before
    # Reroll with 50% certainty if it's passed before
    factor = if prior is /^w+$/ then 2 else 10
    return refresh! if Math.floor(Math.random! * factor)
  $ \#book .text book
  $ \#x .html x.replace(/`/g, \<b>).replace(/~/g, \</b>)
  $ \#y .html y.replace(/`/g, \<b>).replace(/~/g, \</b>)
  $ \#x-key .text x-key
  $ \#y-key .text y-key
  $ \#x-key-link .attr href: "https://www.moedict.tw/##{ x-key }" target: \_blank
  $ \#y-key-link .attr href: "https://www.moedict.tw/##{ y-key }" target: \_blank

  $ \#log .append $(\<tr/> class: \log-line).append(
    $(\<td/> class: \book).text(book).append do
      $("<span><br></span>").append do
        $(\<a/> class: 'ui button mini key-link' href: "##idx" target: \_blank).text "重做"
          .prepend $("<i class='icon repeat'></i>")
    $(\<td/> class: \log-x).html($ \#x .html!).append do
      $("<span><br></span>").append do
        $(\<a/> class: \key-link href: "https://www.moedict.tw/##{ x-key }" target: \_blank).text x-key
          .prepend $("<i class='icon external url'></i>")
    $(\<td/> class: \log-y).html($ \#y .html!).append do
      $("<span><br></span>").append do
        $(\<a/> class: \key-link href: "https://www.moedict.tw/##{ y-key }" target: \_blank).text y-key
          .prepend $("<i class='icon external url'></i>")
    $(\<td/> class: \log-reason)
  )

  $ \.do-search .attr \target \_blank
  $ \.do-search.x .attr \href "https://www.google.com.tw/\#q=\"#{ x.replace(/[`~「」]/g '') }\""
  $ \.do-search.y .attr \href "https://www.google.com.tw/\#q=\"#{ y.replace(/[`~「」]/g '') }\""
# $ \.do-search.z .attr \href "https://www.google.com.tw/\#q=#{ x.replace(/[`~「」]/g '') } #{ y.replace(/[`~「」]/g '') }"

  $ \#reason .val ''
  #$ \#keys .hide!
  $ \#proceed .fadeOut \fast
  $ \.choice .removeClass \green
  $ \.choice .off \click .click ->
    $ \.choice .removeClass \green
    $(@).addClass \green
    $ \.tag .off \click .click ->
      $ \#reason .val ~> "#{ $ \#reason .val! }[#{ $(@).text! }]"
    $ \#proceed .fadeIn \fast ->
      $ \#reason .focus!
