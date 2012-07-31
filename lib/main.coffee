util = require './util'

Server = require './Server'
defaultServer = require './defaultServer'

Client = require './Client'
defaultServer = require './defaultClient'

module.exports =
  createServer: (plugin) ->
    newPlugin = util.mergePlugins defaultServer, plugin
    err = util.validatePlugin newPlugin
    throw new Error "Plugin validation failed: #{err}" if err?
    return new Server newPlugin

  createClient: (plugin) ->
    newPlugin = util.mergePlugins defaultServer, plugin
    err = util.validatePlugin newPlugin
    throw new Error "Plugin validation failed: #{err}" if err?
    return new Client newPlugin