window.our_log = (o) ->
     if window.console && console.log
        console.log.apply(console, if !!arguments.length then arguments else [this])
     else opera && opera.postError && opera.postError(o || this)

window.log_debug = (o) -> log_msg("DEBUG", arguments)
window.log_info = (o) -> log_msg("INFO", arguments)
window.log_warn = (o) -> log_msg("WARN", arguments)
window.log_error = (o) -> log_msg("ERROR", arguments)


# Our internal log allowing a log type
log_msg = (msg,rest) ->
    args = Array.prototype.slice.call(rest)
    r = [msg].concat(args)
    window.our_log.apply(window, r)

    $('.log-list').append("<pre class='#{msg.toLowerCase()}'>#{msg}: #{args}")
    if msg=='ERROR'
        $('.log-link').addClass('error')
    if msg=='ERROR' || msg=='WARN'
        $('.log-link').css('opacity','1')