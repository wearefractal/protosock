ProtoSock = require '../'
connect = require "connect"

app = connect()
app.use connect.static __dirname
server = app.listen 8085

getResponder = (socket, msg) ->
  cookie: (name, val) =>
    return msg.cookies unless key or val
    if key and not val
      return msg.cookies[key]
    else
      msg.cookies[key] = val
      socket.write
        type: 'cookie'
        key: key
        args: val
      return

  reply: (args...) =>
    socket.write
      type: 'response'
      id: msg.id
      service: msg.service
      args: args

  disconnect: -> socket.close()

vein =
  options:
    server: server
    namespace: 'Vein'
    resource: 'default'

  services: {}
  add: (name, fn) -> @services[name] = fn; @
  remove: (name) -> delete @services[name]; @

  inbound: (socket, msg, done) ->
    try
      done JSON.parse msg
    catch err
      @error socket, err

  outbound: (socket, msg, done) ->
    try
      done JSON.stringify msg
    catch err
      @error socket, err

  validate: (socket, msg, done) ->
    return done false unless typeof msg is 'object'
    return done false unless typeof msg.type is 'string'
    if msg.type is 'request'
      return done false unless typeof msg.id is 'string'
      return done false unless typeof msg.service is 'string'
      return done false unless typeof @services[msg.service] is 'function'
      return done false unless Array.isArray msg.args
      return done false if msg.cookies? and typeof msg.cookies isnt 'object'
    else
      return done false
    return done true

  invalid: (socket, msg) -> socket.close()
  connect: (socket) -> 
    socket.write
      type: 'services'
      args: Object.keys @services

  message: (socket, msg) ->
    try
      @services[msg.service] getResponder(socket,msg), msg.args...
    catch err
      @error socket, err

veinServer = ProtoSock.createServer vein

veinServer.add 'add', (res, args...) ->
  result = 0
  result += arg for arg in args
  res.reply result

console.log 'Server running on port 8085'