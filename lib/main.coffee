util = require './util'

ps =
  createClientWrapper: (plugin) -> (opt) -> ps.createClient plugin, opt
  createClient: (plugin, opt) ->
    Client = require './Client'
    defaultClient = require './defaultClient'
    newPlugin = util.mergePlugins defaultClient, plugin
    return new Client newPlugin, opt

`// if node`
require("http").globalAgent.maxSockets = 999 # fix for multiple clients
ps.createServer = (httpServer, plugin, opt) ->
  Server = require './Server'
  defaultServer = require './defaultServer'
  newPlugin = util.mergePlugins defaultServer, plugin
  return new Server httpServer, newPlugin, opt

ps.createServerWrapper = (plugin) -> (httpServer, opt) -> ps.createServer httpServer, plugin, opt

module.exports = ps
return
`// end`

window.ProtoSock = ps
#define(->ProtoSock) if typeof define is 'function'