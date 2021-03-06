{EventEmitter2} = require 'eventemitter2'

class HydrantManager extends EventEmitter2
  constructor: ({@client, @uuidAliasResolver}) ->
    throw new Error('HydrantManager: client is required') unless @client?
    throw new Error('HydrantManager: uuidAliasResolver is required') unless @uuidAliasResolver?

  connect: ({uuid}, callback) =>
    @client.ping (error) =>
      return callback error if error?
      @uuidAliasResolver.resolve uuid, (error, uuid) =>
        return callback error if error?
        @client.on 'message', @_onMessage
        @client.subscribe uuid, callback

  close: =>
    @client.on 'error', (error) =>
      console.error error.stack
      # silently ignore

    if @client.disconnect?
      @client.quit => # ignore error
      @client.disconnect false
      return
    @client.end true

  _onMessage: (channel, messageStr) =>
    try
      message = JSON.parse messageStr
    catch
      @emit 'error', 'Error: unable to parse message'
      return

    @emit 'message', message

module.exports = HydrantManager
