module.exports =
  write: (msg) ->
    @parent.outbound @, msg, (formatted) => @send formatted
    return @

  disconnect: (args...) -> 
    @close args...
    return @