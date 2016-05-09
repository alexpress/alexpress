TypedClass = require '../util/TypedClass'

module.exports = class Request extends TypedClass

  constructor : ( {@type, @original} )->
    @requestId = @original.request.requestId
    @timestamp = @original.request.timestamp
    @version = @original.version
    @new = @original.session.new
    @sessionId = @original.session.sessionId
    @applicationId = @original.session.application.applicationId
    @userId = @original.session.user.userId
    @userAccessToken = @original.session.user.accessToken
    @sessionAttributes = @original.session.attributes or {}
    @_slots = @original.request.intent?.slots or {}

    @init()

  init : ->

  slots : => @_slots

  slot : ( name ) => @_slots[ name ]?.value

  session : ( name ) =>
    if name? then @sessionAttributes[ name ] else @sessionAttributes

  @create : ( opt ) -> super opt, __dirname
    
