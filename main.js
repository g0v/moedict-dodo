// Generated by LiveScript 1.2.0
(function(){
  var split$ = ''.split;
  $(function(){
    var score, key, record, items, MAX, LoadedScripts, restart, grokHash, refreshTotal;
    score = 0;
    key = '';
    record = '';
    items = [];
    $('.hidden').hide();
    MAX = 10;
    $('#quit').click(function(){
      $('.log-line:last').remove();
      return $('#main').fadeOut(function(){
        return $('#again').show();
      });
    });
    $('#next').click(function(){
      var reason, choice, row;
      score++;
      reason = $('#reason').val().replace(/[\n,]/g, '，');
      choice = $('.choice.green').attr('id');
      row = key + "," + choice + "," + reason + "\n";
      switch (choice) {
      case 'x':
        $('.log-x:last').addClass('positive');
        $('.log-y:last').addClass('negative');
        break;
      case 'y':
        $('.log-x:last').addClass('negative');
        $('.log-y:last').addClass('positive');
        break;
      case 'z':
        $('.log-x:last').addClass('warning');
        $('.log-y:last').addClass('warning');
        break;
      case 'w':
        $('.log-x:last').addClass('active');
        $('.log-y:last').addClass('active');
      }
      if (choice !== 'w') {
        window.total++;
      }
      refreshTotal();
      $('.log-reason:last').text(reason);
      $.ajax({
        dataType: 'jsonp',
        url: "https://www.moedict.tw/dodo/log/?log=" + encodeURIComponent(row)
      });
      record += row;
      $('#progress-text').text(score + " / " + MAX);
      $('#progress-bar').css('width', score / MAX * 100 + "%");
      if (score >= MAX) {
        $('#main').fadeOut(function(){
          return $('#again').show();
        });
        return;
      }
      return refresh();
    });
    LoadedScripts = {};
    function getScript(src, cb){
      if (LoadedScripts[src]) {
        return cb();
      }
      LoadedScripts[src] = true;
      return $.ajax({
        type: 'GET',
        url: src,
        dataType: 'script',
        cache: true,
        crossDomain: true,
        complete: cb
      });
    }
    window.restart = restart = function(idx){
      idx == null && (idx = '');
      return window.location = document.URL.replace(/#.*$/, idx);
    };
    window.grokHash = grokHash = function(){
      if (/^#(\d+)/.exec(location.hash)) {
        refresh(RegExp.$1);
        return true;
      }
      return false;
    };
    window.seen = {};
    window.total = 0;
    getScript('data.js', function(){
      items = window.dodoData;
      if (!grokHash()) {
        refresh();
      }
      return $.get('https://www.moedict.tw/dodo/log.txt', function(data){
        var i$, ref$, len$, line, key, val;
        window.seen = data;
        for (i$ = 0, len$ = (ref$ = data.split(/[\r\n]/)).length; i$ < len$; ++i$) {
          line = ref$[i$];
          if (/^([^,]+,[^,]+),([wxyz])/.exec(line)) {
            key = RegExp.$1;
            val = RegExp.$2;
            if (window.seen[key]) {
              window.seen[key] += val;
            } else {
              window.seen[key] = val;
            }
            if (/[xyz]/.exec(val)) {
              window.total++;
            }
          }
        }
        return refreshTotal();
      });
    });
    refreshTotal = window.refreshTotal = function(){
      var percent;
      percent = Math.floor(window.total / items.length * 100);
      $('#total-text').text("目前進度：" + window.total + " / " + items.length + " (" + percent + "%)");
      return $('#total-bar').css('width', percent + "%");
    };
    function pickItem(idx){
      var result, hash, e;
      idx || (idx = Math.floor(Math.random() * items.length));
      result = (function(){
        try {
          return items[+idx];
        } catch (e$) {}
      }());
      if (!result) {
        return pickItem();
      }
      items[idx] = null;
      hash = "#" + idx;
      if (/^#(\d+)/.exec(location.hash) && location.hash + "" !== hash) {
        try {
          history.pushState(null, null, hash);
        } catch (e$) {
          e = e$;
          location.replace(hash);
        }
      }
      return result + "\n" + idx;
    }
    function refresh(fixedIdx){
      var ref$, book, xKey, x, yKey, y, idx, prior, factor;
      ref$ = split$.call(pickItem(fixedIdx), '\n'), book = ref$[0], xKey = ref$[1], x = ref$[2], yKey = ref$[3], y = ref$[4], idx = ref$[5];
      key = xKey + "," + yKey;
      if (!fixedIdx && (prior = window.seen[key])) {
        factor = /^w+$/.exec(prior) ? 2 : 10;
        if (Math.floor(Math.random() * factor)) {
          return refresh();
        }
      }
      $('#book').text(book);
      $('#x').html(x.replace(/`/g, '<b>').replace(/~/g, '</b>'));
      $('#y').html(y.replace(/`/g, '<b>').replace(/~/g, '</b>'));
      $('#x-key').text(xKey);
      $('#y-key').text(yKey);
      $('#x-key-link').attr({
        href: "https://www.moedict.tw/#" + xKey,
        target: '_blank'
      });
      $('#y-key-link').attr({
        href: "https://www.moedict.tw/#" + yKey,
        target: '_blank'
      });
      $('#log').append($('<tr/>', {
        'class': 'log-line'
      }).append($('<td/>', {
        'class': 'book'
      }).text(book).append($("<span><br></span>").append($('<a/>', {
        'class': 'ui button mini key-link',
        href: "#" + idx,
        target: '_blank'
      }).text("重做").prepend($("<i class='icon repeat'></i>")))), $('<td/>', {
        'class': 'log-x'
      }).html($('#x').html()).append($("<span><br></span>").append($('<a/>', {
        'class': 'key-link',
        href: "https://www.moedict.tw/#" + xKey,
        target: '_blank'
      }).text(xKey).prepend($("<i class='icon external url'></i>")))), $('<td/>', {
        'class': 'log-y'
      }).html($('#y').html()).append($("<span><br></span>").append($('<a/>', {
        'class': 'key-link',
        href: "https://www.moedict.tw/#" + yKey,
        target: '_blank'
      }).text(yKey).prepend($("<i class='icon external url'></i>")))), $('<td/>', {
        'class': 'log-reason'
      })));
      $('.do-search').attr('target', '_blank');
      $('.do-search.x').attr('href', "https://www.google.com.tw/#q=\"" + x.replace(/[`~「」]/g, '') + "\"");
      $('.do-search.y').attr('href', "https://www.google.com.tw/#q=\"" + y.replace(/[`~「」]/g, '') + "\"");
      $('#reason').val('');
      $('#proceed').fadeOut('fast');
      $('.choice').removeClass('green');
      return $('.choice').off('click').click(function(){
        $('.choice').removeClass('green');
        $(this).addClass('green');
        $('.tag').off('click').click(function(){
          var this$ = this;
          return $('#reason').val(function(){
            return $('#reason').val() + "[" + $(this$).text() + "]";
          });
        });
        return $('#proceed').fadeIn('fast', function(){
          return $('#reason').focus();
        });
      });
    }
    return refresh;
  });
}).call(this);
