util = require './util'
throw 'ProtoSock server wis not for the browser' if isBrowser = util.isBrowser()

engineServer = require 'engine.io'
util.extendSocket engineServer.Socket

class Server
  constructor: (plugin) ->
    @[k]=v for k,v of plugin
    @isServer = true
    @isClient = false
    @isBrowser = isBrowser
    throw 'server option required' unless @options.server?

    eiopts =
      path: "/#{@options.namespace}"
      resource: @options.resource
      transports: @options.transports
      cookie: @options.cookie
      policyFile: @options.policyFile
      allowUpgrades: @options.upgrades?.allow
      destroyUpgrade: @options.upgrades?.destroy
      pingTimeout: @options.ping?.timeout
      pingInterval: @options.ping?.interval
      debug: @options.debug

    @server = engineServer.attach @options.server, eiopts
    @server.httpServer = @options.server
    @server.on 'connection', @handleConnection
    @start()

  # Closes HTTP server
  # TODO: close websocket handlers without closing http
  destroy: => @server.httpServer.close(); @

  # Disconnects all clients
  disconnect: => @server.close(); @

  # Handle connection
  handleConnection: (socket) =>
    socket.parent = @
    socket.on 'message', (msg) => @handleMessage socket, msg
    socket.on 'error', (err) => @handleError socket, err
    socket.on 'close', (reason) => @handleClose socket, reason
    @connect socket

  # Handle socket message
  handleMessage: (socket, msg) =>
    @inbound socket, msg, (formatted) =>
      @validate socket, formatted, (valid) =>
        if valid is true
          @message socket, formatted
        else if valid is false
          @invalid socket, formatted
    
  # Handle socket error
  handleError: (socket, err) =>
    err = new Error err if typeof err is 'string'
    @error socket, err

  # Handle socket close
  handleClose: (socket, reason) => @close socket, reason

module.exports = Server