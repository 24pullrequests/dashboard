class Dashing.Countdown extends Dashing.Widget

  ready: ->
    setInterval(@startCountdown, 500)

  startCountdown: =>
    current_timestamp = Math.round(new Date().getTime()/1000)
    end_timestamp = Math.round( Date.parse($(@node).find(".more-info").html())/1000 )
    seconds_until_end = end_timestamp - current_timestamp
    if seconds_until_end < 3600
      $(@node).parent().remove()
    else if seconds_until_end < 0
      @set('timeleft', "TIME UP!")
      for i in [0..100] by 1
        $(@node).fadeTo('fast', 0).fadeTo('fast', 1.0)
    else
      d = Math.floor(seconds_until_end/86400)
      h = Math.floor((seconds_until_end-(d*86400))/3600)
      m = Math.floor((seconds_until_end-(d*86400)-(h*3600))/60)
      s = seconds_until_end-(d*86400)-(h*3600)-(m*60)
      if d >0
        dayname = 'day'
        if d > 1
          dayname = 'days'
        @set('timeleft', d + " "+dayname+" " + @formatTime(h) + ":" + @formatTime(m) + ":" + @formatTime(s))
      else
        @set('timeleft', @formatTime(h) + ":" + @formatTime(m) + ":" + @formatTime(s))


  formatTime: (i) ->
    if i < 10 then "0" + i else i
