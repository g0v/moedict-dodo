<- $

score = 0
key = ''
record = ''
$ \#proceed .hide!

items = window.dodo-data
MAX = 10

$ \#skip .click -> refresh!
$ \#next .click ->
  score++
  row = "#key,#{ $ \.choice.green .attr \id },#{ $ \#reason .val! .replace(/[\n,]/g \，) }\n"
  $.ajax({ dataType: 'jsonp', url: "https://www.moedict.tw/dodo/log/?log=#row" })
  record += row
  $ \#progress-text .text "#score / #MAX"
  $ \#progress-bar .css \width "#{ score / MAX * 100 }%"
  if score >= MAX
    $ \#again-info .text "試玩結束，感謝您的參與！已經送出以下紀錄：\n\n#record"
    $ \.choice .off \click
    $ \#main .fadeOut!
    $ \#again .fadeIn!
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
