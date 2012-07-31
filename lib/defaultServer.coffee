def =
  options: {}
  start: ->

  inbound: (socket, msg, done) -> done JSON.parse msg
  outbound: (socket, msg, done) -> done JSON.stringify msg

  validate: (socket, msg, done) -> done true
  invalid: (socket, msg) ->

  connect: (socket) ->
  message: (socket, msg) ->
  error: (socket, err) ->
  close: (socket, reason) ->

module.exports = def