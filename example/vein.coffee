isBrowser = typeof window isnt 'undefined'

getId = =>
  rand = -> (((1 + Math.random()) * 0x10000000) | 0).toString 16
  rand()+rand()+rand()

vein =
  options:
    namespace: 'Vein'
    resource: 'default'

  start: ->
    @services = {}
    @callbacks = {}

  inbound: (socket, msg, done) ->
    try
      done JSON.parse msg
    catch err
      @error socket, err

  outbound: (socket, msg, done) ->
    try
      done JSON.stringify msg
    catch err
      @error socket,  err

  validate: (socket, msg, done) ->
    return done false unless typeof msg is 'object'
    return done false unless typeof msg.type is 'string'
    if msg.type is 'response'
      return done false unless typeof msg.id is 'string'
      return done false unless typeof @callbacks[msg.id] is 'function'
      return done false unless typeof msg.service is 'string'
      return done false unless Array.isArray msg.args
    else if msg.type is 'cookie'
      return done false unless typeof msg.key is 'string'
      return done false if msg.args? and typeof msg.args isnt 'string'
    else if msg.type is 'services'
      return done false unless Array.isArray msg.args
    else
      return done false
    return done true

  error: (socket, err) -> throw err

  message: (socket, msg) ->
    if msg.type is 'response'
      @callbacks[msg.id] msg.args...
    else if msg.type is 'cookie'
      # TODO: implement
    else if msg.type is 'services'
      @services = msg.args
      @[k]=@getSender(socket,k) for k in @services
      @emit 'ready', @services

  getSender: (socket, service) ->
    (args..., cb) =>
      id = getId()
      @callbacks[id] = cb
      socket.write
        type: 'request'
        id: id
        service: service
        args: args
        cookies: {} # TODO: implement

window.Vein =
  create: (opt={}) ->
    vein.options[k]=v for k,v of opt
    return ProtoSock.createClient vein