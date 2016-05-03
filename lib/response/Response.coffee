OutputSpeech = require '../outputSpeech'

module.exports = class Response
  constructor : ( opts = {} ) ->
    @locals = {}
    @data =
      version : "1.0"
      sessionAttributes : {}
      response :
        shouldEndSession : true

    @out = opts.out or throw new Error ("missing option: out")
    @app = opts.app or throw new Error ("missing option: app")
    @req = opts.req or throw new Error ("missing option: req")
    @session( @req.sessionAttributes ) if @app.get( "persist session" )

  version : => @data.version

  keepAlive : ( val ) =>
    return !@data.response.shouldEndSession if typeof val is 'undefined'
    @data.response.shouldEndSession = !val
    @

  session : ( name, value ) =>
    if value?
      @data.sessionAttributes[ name ] = value
    else
      return @data.sessionAttributes[ name ] if typeof name is 'string'
      @data.sessionAttributes[ k ] = v for own k,v of name
    @

  ssml : ( str ) =>
    return @data.response.outputSpeech.ssml unless str?
    @data.response.outputSpeech = OutputSpeech.create type : 'SSML', ssml : str
    @end()

  text : ( str ) =>
    return @data.response.outputSpeech.text unless str?
    @data.response.outputSpeech = OutputSpeech.create type : 'PlainText', text : str
    @end()

  reprompt : ( str ) =>
    return @data.response.reprompt unless str?
    s = OutputSpeech.create type : @app.get( "format" )
    s.append str
    @data.response.reprompt =
      outputSpeech : s
    @

  ask : =>
    @keepAlive true
    @send.apply null, arguments

  tell : =>
    @keepAlive false
    @send.apply null, arguments

  send : ( args... ) =>
    args = args[ 0 ] while Array.isArray( args[ 0 ] ) and args.length is 1
    @reprompt args[ 1 ] if args.length > 1

    str = args[ 0 ]
    format = @app.get( "format" )
    return @ssml str if format is "SSML"
    return @text str if format is "PlainText"
    @req.next new Error( "unknown format: #{format}" )

  render : ( view, options, cb ) =>
    req = @req
    opt = options or {}

    if typeof options is 'function'
      done = options
      opts = {}

    opts._locals = @locals

    unless done?
      done = ( err, str ) =>
        return req.next err if err?

        format = @app.get( "format" )
        return @ssml str if format is "SSML"
        return @text str if format is "PlainText"
        req.next new Error( "unknown format: #{format}" )

    @app.render view, opts, done

  end : => @out()
    
