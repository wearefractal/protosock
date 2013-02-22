(function() {
  var Client, EventEmitter, engineClient, getDelay, util,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  util = require('./util');

  if (typeof window !== "undefined" && window !== null) {
    engineClient = require('engine.io');
    EventEmitter = require('emitter');
  } else {
    engineClient = require('engine.io-client');
    EventEmitter = require('events').EventEmitter;
  }

  util.extendSocket(engineClient.Socket);

  getDelay = function(a) {
    if (a > 10) {
      return 15000;
    } else if (a > 5) {
      return 5000;
    } else if (a > 3) {
      return 1000;
    }
    return 1000;
  };

  Client = (function(_super) {

    __extends(Client, _super);

    function Client(plugin, options) {
      var eiopts, k, v, _base, _base2, _base3;
      if (options == null) options = {};
      this.reconnect = __bind(this.reconnect, this);
      this.handleClose = __bind(this.handleClose, this);
      this.handleError = __bind(this.handleError, this);
      this.handleMessage = __bind(this.handleMessage, this);
      this.handleConnection = __bind(this.handleConnection, this);
      for (k in plugin) {
        v = plugin[k];
        this[k] = v;
      }
      for (k in options) {
        v = options[k];
        this.options[k] = v;
      }
      if ((_base = this.options).reconnect == null) _base.reconnect = true;
      if ((_base2 = this.options).reconnectLimit == null) {
        _base2.reconnectLimit = Infinity;
      }
      if ((_base3 = this.options).reconnectTimeout == null) {
        _base3.reconnectTimeout = Infinity;
      }
      this.isServer = false;
      this.isClient = true;
      this.isBrowser = typeof window !== "undefined" && window !== null;
      eiopts = {
        host: this.options.host,
        port: this.options.port,
        secure: this.options.secure,
        path: "/" + this.options.namespace,
        resource: this.options.resource,
        transports: this.options.transports,
        upgrade: this.options.upgrade,
        flashPath: this.options.flashPath,
        policyPort: this.options.policyPort,
        forceJSONP: this.options.forceJSONP,
        forceBust: this.options.forceBust,
        debug: this.options.debug
      };
      this.ssocket = new engineClient(eiopts);
      this.ssocket.parent = this;
      this.ssocket.once('open', this.handleConnection);
      this.ssocket.on('error', this.handleError);
      this.ssocket.on('message', this.handleMessage);
      this.ssocket.on('close', this.handleClose);
      this.start();
      return;
    }

    Client.prototype.disconnect = function(temporary) {
      if (!temporary) this.options.reconnect = false;
      if (this.ssocket.readyState === 'open') this.ssocket.disconnect();
      return this;
    };

    Client.prototype.destroy = function() {
      this.options.reconnect = false;
      this.disconnect();
      this.emit("destroyed");
      return this;
    };

    Client.prototype.handleConnection = function() {
      this.emit('connected');
      return this.connect(this.ssocket);
    };

    Client.prototype.handleMessage = function(msg) {
      var _this = this;
      this.emit('inbound', this.ssocket, msg);
      return this.inbound(this.ssocket, msg, function(formatted) {
        return _this.validate(_this.ssocket, formatted, function(valid) {
          if (valid) {
            _this.emit('message', _this.ssocket, formatted);
            return _this.message(_this.ssocket, formatted);
          } else {
            _this.emit('invalid', _this.ssocket, formatted);
            return _this.invalid(_this.ssocket, formatted);
          }
        });
      });
    };

    Client.prototype.handleError = function(err) {
      if (typeof err === 'string') err = new Error(err);
      return this.error(this.ssocket, err);
    };

    Client.prototype.handleClose = function(reason) {
      var _this = this;
      if (this.ssocket.reconnecting) return;
      if (this.options.reconnect) {
        return this.reconnect(function(err) {
          if (err == null) return;
          _this.emit('close', _this.ssocket, reason);
          return _this.close(_this.ssocket, reason);
        });
      } else {
        this.emit('close', this.ssocket, reason);
        return this.close(this.ssocket, reason);
      }
    };

    Client.prototype.reconnect = function(cb) {
      var attempts, connect, done, err, maxAttempts, start, timeout,
        _this = this;
      if (this.ssocket.reconnecting) return cb("Already reconnecting");
      this.ssocket.reconnecting = true;
      this.disconnect();
      start = Date.now();
      maxAttempts = this.options.reconnectLimit;
      timeout = this.options.reconnectTimeout;
      attempts = 0;
      done = function() {
        _this.ssocket.reconnecting = false;
        _this.emit("reconnected");
        return cb();
      };
      err = function(e) {
        _this.ssocket.reconnecting = false;
        return cb(e);
      };
      this.ssocket.once('open', done);
      connect = function() {
        if (!_this.ssocket.reconnecting) return;
        if (attempts >= maxAttempts) return err("Exceeded max attempts");
        if ((Date.now() - start) > timeout) return err("Timeout on reconnect");
        attempts++;
        _this.ssocket.open();
        return setTimeout(connect, getDelay(attempts));
      };
      return setTimeout(connect, getDelay(attempts));
    };

    return Client;

  })(EventEmitter);

  module.exports = Client;

}).call(this);
