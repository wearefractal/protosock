util = require './util'
isBrowser = util.isBrowser()

ps =
  createServer: (plugin) ->
    Server = require './Server'
    defaultServer = require './defaultServer'
    throw 'ProtoSock server is not for the browser' if isBrowser
    newPlugin = util.mergePlugins defaultServer, plugin
    err = util.validatePlugin newPlugin
    throw new Error "Plugin validation failed: #{err}" if err?
    return new Server newPlugin

  createClient: (plugin) ->
    Client = require './Client'
    defaultClient = require './defaultClient'
    newPlugin = util.mergePlugins defaultClient, plugin
    err = util.validatePlugin newPlugin
    throw new Error "Plugin validation failed: #{err}" if err?
    return new Client newPlugin

if isBrowser
  window.ProtoSock = ps
else
  module.exports = ps