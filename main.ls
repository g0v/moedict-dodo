<- $
score = 0
key = ''
record = ''
items = []
$ \#proceed .hide!

MAX = 10

$ \#skip .click ->
  $ \.log-line:last .remove!
  refresh!
$ \#next .click ->
  score++
  reason = $ \#reason .val! .replace(/[\n,]/g \，)
  row = "#key,#{ $ \.choice.green .attr \id },#reason\n"
  switch $ \.choice.green .attr \id
  | \x => $(\.log-x:last).addClass \positive; $(\.log-y:last).addClass \negative
  | \y => $(\.log-x:last).addClass \negative; $(\.log-y:last).addClass \positive
  | \z => $(\.log-x:last).addClass \warning; $(\.log-y:last).addClass \warning
  $ \.log-reason:last .text reason
  $.ajax({ dataType: 'jsonp', url: "https://www.moedict.tw/dodo/log/?log=#{ encodeURIComponent row }" })
  record += row
  $ \#progress-text .text "#score / #MAX"
  $ \#progress-bar .css \width "#{ score / MAX * 100 }%"
  if score >= MAX
    $ \.choice .off \click
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

getScript \data.js ->
  items := window.dodo-data
  refresh!

function refresh
  [book, x-key, x, y-key, y] = items[Math.floor(Math.random! * items.length)] / '\n'
  key := "#x-key,#y-key"
  $ \#book .text book
  $ \#x .html x.replace(/`/g, \<b>).replace(/~/g, \</b>)
  $ \#y .html y.replace(/`/g, \<b>).replace(/~/g, \</b>)
  $ \#x-key .text x-key .attr href: "https://www.moedict.tw/##{ x-key }" target: \_blank
  $ \#y-key .text y-key .attr href: "https://www.moedict.tw/##{ y-key }" target: \_blank

  $ \#log .append $(\<tr/> class: \log-line).append(
    $(\<td/> class: \book).text(book)
    $(\<td/> class: \log-x).html($ \#x .html!).append do
      $("<span><br><i class='icon book'></i></span>").append do
        $(\<a/> href: "https://www.moedict.tw/##{ x-key }" target: \_blank).text x-key
    $(\<td/> class: \log-y).html($ \#y .html!).append do
      $("<span><br><i class='icon book'></i></span>").append do
        $(\<a/> href: "https://www.moedict.tw/##{ y-key }" target: \_blank).text y-key
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
  $ \.choice .click ->
    $ \.choice .removeClass \green
    $(@).addClass \green
    #$ \#keys .show!
    $ \#proceed .fadeIn \fast -> $ \#reason .focus!
