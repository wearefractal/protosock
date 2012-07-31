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

util = require './util'
isBrowser = util.isBrowser()

if isBrowser
  def.options = 
    host: window.location.hostname
    port: (if window.location.port.length > 0 then parseInt window.location.port else 80)
    secure: (window.location.protocol is 'https:')

module.exports = def