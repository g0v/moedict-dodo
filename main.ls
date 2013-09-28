<- $

score = 0
key = ''
record = ''
$ \#proceed .hide!

items = window.dodo-data

$ \#skip .click -> refresh!
$ \#next .click ->
  score++
  row = "#key,#{ $ \.choice.green .attr \id },#{ $ \#reason .val! .replace(/[\n,]/g \，) }\n"
  $.ajax({ dataType: 'jsonp', url: "https://moedict.tw/dodo/log/?log=#row" })
  record += row
  $ \#progress-text .text "#score / 5"
  $ \#progress-bar .css \width "#{ score / 5 * 100 }%"
  if score is 5
    alert \試玩結束！
    alert record
    $ \.choice .off \click
    $ \#next .fadeOut \fast
    $ \#skip .fadeOut \fast
    return
  refresh!
refresh!

function refresh
  [book, x-key, x, y-key, y] = items[Math.floor(Math.random! * items.length)] / '\n'
  key := "#x-key,#y-key"
  $ \#book .text book
  $ \#x .html x.replace(/`/g, \<b>).replace(/~/g, \</b>)
  $ \#y .html y.replace(/`/g, \<b>).replace(/~/g, \</b>)

  $ \.do-search .attr \target \_blank
  $ \.do-search.x .attr \href "https://www.google.com.tw/\#q=\"#{ x.replace(/[`~「」]/g '') }\""
  $ \.do-search.y .attr \href "https://www.google.com.tw/\#q=\"#{ y.replace(/[`~「」]/g '') }\""
# $ \.do-search.z .attr \href "https://www.google.com.tw/\#q=#{ x.replace(/[`~「」]/g '') } #{ y.replace(/[`~「」]/g '') }"

  $ \#reason .val ''
  $ \#proceed .fadeOut \fast
  $ \.choice .removeClass \green
  $ \.choice .click ->
    $ \.choice .removeClass \green
    $(@).addClass \green
    $ \#proceed .fadeIn \fast -> $ \#reason .focus!
