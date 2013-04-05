ProtoSock = require '../'
should = require 'should'
require 'mocha'

http = require 'http'

port = 9092
getServer = -> http.createServer().listen ++port

TestProtocolServer = require './plugins/TestServer'
TestProtocol = require './plugins/TestClient'

describe 'Client', ->
  describe 'createClient()', ->
    it 'should construct from test protocol', (done) ->
      server = ProtoSock.createServer getServer(), TestProtocolServer()
      testProtocol = TestProtocol server
      client = ProtoSock.createClient testProtocol
      should.exist client
      done()

  describe 'plugin interaction', ->
    describe 'start()', ->
      it 'should call when client is created', (done) ->
        server = ProtoSock.createServer getServer(), TestProtocolServer()
        testProtocol = TestProtocol server
        testProtocol.start = ->
          @isBrowser.should.be.false
          @isClient.should.be.true
          done()
        client = ProtoSock.createClient testProtocol

    describe 'connect()', ->
      it 'should call when socket is connected', (done) ->
        server = ProtoSock.createServer getServer(), TestProtocolServer()
        testProtocol = TestProtocol server
        testProtocol.connect = -> done()
        client = ProtoSock.createClient testProtocol

    describe 'inbound()', ->
      it 'should call when server sends a message', (done) ->
        tp = TestProtocolServer()
        tp.connect = (socket) ->
          should.exist socket
          socket.write test: 'test'
        server = ProtoSock.createServer getServer(), tp

        testProtocol = TestProtocol server
        testProtocol.inbound = (socket, msg, next) ->
          should.exist socket
          should.exist msg
          should.exist next
          should.exist msg
          msg.should.equal JSON.stringify test: 'test'
          done()
        client = ProtoSock.createClient testProtocol

    describe 'outbound()', ->
      it 'should call when client sends a message', (done) ->
        server = ProtoSock.createServer getServer(), TestProtocolServer()
        testProtocol = TestProtocol server
        testProtocol.outbound = (socket, msg, next) ->
          should.exist socket
          should.exist msg
          should.exist next
          should.exist msg.test
          msg.test.should.equal 'test'
          done()
        testProtocol.connect = (socket) ->
          should.exist socket
          socket.write test: 'test'
        client = ProtoSock.createClient testProtocol

    describe 'write()', ->
      it 'should call when client sends a message', (done) ->
        tp = TestProtocolServer()
        tp.message = (socket, msg) ->
          should.exist socket
          should.exist msg
          should.exist msg.test
          msg.test.should.equal 'test'
          done()
        server = ProtoSock.createServer getServer(), tp

        testProtocol = TestProtocol server
        testProtocol.connect = (socket) ->
          should.exist socket
          socket.write test: 'test'
        client = ProtoSock.createClient testProtocol

    describe 'validate()', ->
      it 'should call when server sends a message', (done) ->
        tp = TestProtocolServer()
        tp.connect = (socket) ->
          should.exist socket
          socket.write test: 'test'
        serv = ProtoSock.createServer getServer(), tp

        testProtocol = TestProtocol serv
        testProtocol.validate = (socket, msg, next) ->
          should.exist socket
          should.exist msg
          should.exist next
          should.exist msg.test
          msg.test.should.equal 'test'
          done()
        client = ProtoSock.createClient testProtocol

    describe 'invalid()', ->
      it 'should call when server sends a message and validate returns false', (done) ->
        tp = TestProtocolServer()
        tp.connect = (socket) ->
          should.exist socket
          socket.write test: 'test'
        server = ProtoSock.createServer getServer(), tp

        testProtocol = TestProtocol server
        testProtocol.validate = (socket, msg, validate) -> validate false
        testProtocol.invalid = (socket, msg) ->
          should.exist socket
          should.exist msg
          should.exist msg.test
          msg.test.should.equal 'test'
          done()
        client = ProtoSock.createClient testProtocol

    describe 'message()', ->
      it 'should call when server sends a message and validate returns true', (done) ->
        tp = TestProtocolServer()
        tp.validate = (socket, msg, validate) -> validate true
        tp.connect = (socket) ->
          should.exist socket
          socket.write test: 'test'
        server = ProtoSock.createServer getServer(), tp

        testProtocol = TestProtocol server
        testProtocol.message = (socket, msg) ->
          should.exist socket
          should.exist msg
          should.exist msg.test
          msg.test.should.equal 'test'
          done()
        client = ProtoSock.createClient testProtocol

    describe 'error()', ->
      it 'should call when socket emits an error', (done) ->
        server = ProtoSock.createServer getServer(), TestProtocolServer()
        testProtocol = TestProtocol server
        testProtocol.connect = (socket) -> socket.emit 'error', 'test'
        testProtocol.error = (socket, err) ->
          should.exist socket
          should.exist err
          should.exist err.message
          err.message.should.equal 'test'
          done()
        client = ProtoSock.createClient testProtocol

    describe 'close()', ->
      it 'should call when socket closes', (done) ->
        server = ProtoSock.createServer getServer(), TestProtocolServer()
        testProtocol = TestProtocol server
        testProtocol.options.reconnect = false
        testProtocol.connect = (socket) -> @disconnect()
        testProtocol.close = (socket, reason) ->
          should.exist socket
          should.exist reason
          done()
        client = ProtoSock.createClient testProtocol

    describe 'reconnect()', ->
      it 'should work', (done) ->
        @timeout 5000
        tp = TestProtocolServer()
        tp.message = (socket, msg) ->
          should.exist socket
          should.exist msg
          should.exist msg.test
          msg.test.should.equal 'test'
          done()
        server = ProtoSock.createServer getServer(), tp

        testProtocol = TestProtocol server
        testProtocol.connect = (socket) ->
          should.exist socket
          client.reconnect (err) ->
            should.not.exist err
            socket.write test: 'test'
        client = ProtoSock.createClient testProtocol

      it 'should emit events properly', (done) ->
        @timeout 5000
        tp = TestProtocolServer()
        tp.message = (socket, msg) ->
          should.exist socket
          should.exist msg
          should.exist msg.test
          msg.test.should.equal 'test'
        server = ProtoSock.createServer getServer(), tp

        testProtocol = TestProtocol server
        testProtocol.connect = (socket) ->
          should.exist socket
          client.reconnect (err) ->
            should.not.exist err
            socket.write test: 'test'
        client = ProtoSock.createClient testProtocol
        client.on "reconnected", done

      it 'should fail after X attempts', (done) ->
        @timeout 5000
        tp = TestProtocolServer()
        tp.connect = ->
          server.destroy()
        server = ProtoSock.createServer getServer(), tp

        testProtocol = TestProtocol server
        testProtocol.options.reconnectLimit = 2
        testProtocol.connect = (socket) ->
          should.exist socket
          socket.write test: 'test'
        testProtocol.close = ->
          done()
        client = ProtoSock.createClient testProtocol

      it 'should fail after X seconds', (done) ->
        tp = TestProtocolServer()
        tp.connect = ->
          server.destroy()
        server = ProtoSock.createServer getServer(), tp

        testProtocol = TestProtocol server
        testProtocol.options.reconnectTimeout = 500
        testProtocol.connect = (socket) ->
          should.exist socket
          socket.write test: 'test'
        testProtocol.close = ->
          done()
        client = ProtoSock.createClient testProtocol

      it 'should call on close and buffer messages', (done) ->
        @timeout 2000
        tp = TestProtocolServer()
        tp.message = (socket, msg) ->
          should.exist socket
          should.exist msg
          should.exist msg.test
          msg.test.should.equal 'test'
          done()
        server = ProtoSock.createServer getServer(), tp

        testProtocol = TestProtocol server
        testProtocol.connect = (socket) ->
          should.exist socket
          client.disconnect true
          socket.write test: 'test'
        client = ProtoSock.createClient testProtocol

      it 'should destroy connection', (done) ->
        verify = ->
          should.exist server?.server?.clientsCount, 'expected clientsCount at close'
          server.server.clientsCount.should.eql 0
          done()

        server = ProtoSock.createServer getServer(), TestProtocolServer()
        server.on 'close', (err) ->
          setTimeout verify, 1

        testProtocol = TestProtocol server
        testProtocol.connect = (socket) ->
          should.exist server?.server?.clientsCount, 'expected clientsCount at connect'
          server.server.clientsCount.should.eql 1
          client.destroy()

        client = ProtoSock.createClient testProtocol
