(function() {
  var sock;

  sock = {
    write: function(msg) {
      var _this = this;
      this.parent.outbound(this, msg, function(fmt) {
        return _this.send(fmt);
      });
      return this;
    },
    disconnect: function(r) {
      this.close(r);
      return this;
    }
  };

  module.exports = sock;

}).call(this);
