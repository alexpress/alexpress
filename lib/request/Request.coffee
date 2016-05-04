TypedClass = require '../util/TypedClass'

module.exports = class Request extends TypedClass
  constructor : ( {@type, @original} )->

    @version = @original.version

    for f in [ "requestId", "timestamp" ]
      @[ f ] = @original.request[ f ]

    @new = @original.session.new
    @sessionId = @original.session.sessionId
    @applicationId = @original.session.application.applicationId
    @userId = @original.session.user.userId
    @userAccessToken = @original.session.user.accessToken
    @sessionAttributes = @original.session.attributes or {}

    @init()

  init : =>

  session : ( name ) =>
    @sessionAttributes[ name ]

  @create : ( opt ) -> super opt, __dirname
    
