module.exports =
  extendSocket: (Socket) ->
    nu = require './Socket'
    Socket.prototype extends nu

  mergePlugins: (args...) ->
    newPlugin = {}
    newPlugin extends plugin for plugin in args
    return newPlugin

  validatePlugin: (plugin) ->
    # options
    return 'missing options object' unless typeof plugin.options is 'object'
    return 'namespace option required' unless typeof plugin.options.namespace is 'string'
    return 'resource option required' unless typeof plugin.options.resource is 'string'

    # plugin structure
    return 'missing inbound formatter' unless typeof plugin.inbound is 'function'
    return 'missing outbound formatter' unless typeof plugin.outbound is 'function'
    return 'missing validate' unless typeof plugin.validate is 'function'
    return

  isBrowser: ->
    if window?
      return true
    else if module? and global? and process?
      return false
    else
      console.log 'Unable to determine isBrowser'
      return false
