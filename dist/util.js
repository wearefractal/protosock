(function() {
  var nu, util,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; },
    __slice = Array.prototype.slice;

  nu = require('./Socket');

  util = {
    extendSocket: function(Socket) {
      return __extends(Socket.prototype, nu);
    },
    mergePlugins: function() {
      var args, k, newPlugin, plugin, v, _i, _len;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      newPlugin = {};
      for (_i = 0, _len = args.length; _i < _len; _i++) {
        plugin = args[_i];
        for (k in plugin) {
          v = plugin[k];
          if (typeof v === 'object' && k !== 'server') {
            newPlugin[k] = util.mergePlugins(newPlugin[k], v);
          } else {
            newPlugin[k] = v;
          }
        }
      }
      return newPlugin;
    }
  };

  module.exports = util;

}).call(this);
