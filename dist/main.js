(function() {
  var Client, Server, defaultClient, defaultServer, ps, util;

  util = require('./util');

  Client = require('./Client');

  defaultClient = require('./defaultClient');

  ps = {
    createClientWrapper: function(plugin) {
      return function(opt) {
        return ps.createClient(plugin, opt);
      };
    },
    createClient: function(plugin, opt) {
      var newPlugin;
      newPlugin = util.mergePlugins(defaultClient, plugin);
      return new Client(newPlugin, opt);
    }
  };

  if (!(typeof window !== "undefined" && window !== null)) {
    Server = require('./Server');
    defaultServer = require('./defaultServer');
    require("http").globalAgent.maxSockets = 999;
    ps.createServer = function(httpServer, plugin, opt) {
      var newPlugin;
      newPlugin = util.mergePlugins(defaultServer, plugin);
      return new Server(httpServer, newPlugin, opt);
    };
    ps.createServerWrapper = function(plugin) {
      return function(httpServer, opt) {
        return ps.createServer(httpServer, plugin, opt);
      };
    };
  }

  module.exports = ps;

}).call(this);
