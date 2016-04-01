{EventEmitter2} = require 'eventemitter2'

class HydrantManager extends EventEmitter2
  constructor: ({@client, @uuidAliasResolver, @uuid}) ->
    throw new Error('HydrantManager: client is required') unless @client?
    throw new Error('HydrantManager: uuid is required') unless @uuid?
    throw new Error('HydrantManager: uuidAliasResolver is required') unless @uuidAliasResolver?

  connect: (callback) =>
    @uuidAliasResolver.resolve @uuid, (error, @uuid) =>
      return callback error if error?
      @client.on 'message', @_onMessage
      @client.subscribe @uuid, callback

  close: =>
    if @client.quit?
      @client.quit()
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