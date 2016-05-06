OutputSpeech = require './outputSpeech'
Card = require './card'
speech = require './Speech'
merge = require 'merge'
EventEmitter = require( 'events' ).EventEmitter
makeProps = require './util/makeProps'

module.exports = class Response extends EventEmitter

  constructor : ( opts = {} ) ->
    @locals = {}

    @data =
      version : "1.0"
      sessionAttributes : {}
      response : {}

    for o in [ "app", "out" ]
      @[ o ] = opts[ o ] or throw new Error ("missing option: #{o}")

    @[ o ] = @app[ o ] for o in [ "req" ]
    @_rFormat = @_format = @app.get 'format'
    @keepAlive @app.get( 'keep alive' )


  version : => @data.version

  keepAlive : ( val ) =>
    return !@data.response.shouldEndSession if arguments.length is 0
    @data.response.shouldEndSession = !val
    @

  session : ( name, value ) =>
    sa = @data.sessionAttributes
    if value?
      sa[ name ] = value
      return @

    t = typeof name
    return sa[ name ] if t is 'string'
    return sa[ k ] = v for own k,v of name if t is 'object'
    sa

  format : ( f, rf ) =>
    return @_format if arguments.length is 0
    if @_format != f
      @_format = f
      @os undefined
    @repromptFormat rf if rf?
    @

  repromptFormat : ( val ) =>
    return @_rFormat if arguments.length is 0
    if @_rFormat != val
      @_rFormat = val
      @ros undefined
    @

  card : => @_card

  simpleCard : ( title, content ) =>
    @_card = Card.create type : "Simple"
    .title title
    .content content
    @

  standardCard : ( title, text, smallImageUrl, largeImageUrl ) =>
    @_card = Card.create type : "Standard"
    .title title
    .text text
    .smallImageUrl smallImageUrl
    .largeImageUrl largeImageUrl
    @

  linkAccountCard : () =>
    @_card = Card.create type : "LinkAccount"
    @keepAlive false # user must use app for account linking
    @

  speech : ( str ) => @_speech @os(), str

  reprompt : ( str ) => @_speech @ros(), str

  ask : ( speech, prompt ) => @keepAlive( true ).send speech, prompt

  tell : ( speech, prompt ) => @keepAlive( false ).send speech, prompt

  ssml : ( speech, prompt ) => @format( "SSML" ).send speech, prompt

  plainText : ( speech, prompt ) => @format( "PlainText" ).send speech, prompt

  send : ( speech, prompt ) =>
    [speech, prompt] = speech if Array.isArray speech
    @reprompt prompt if prompt?
    @speech speech if speech?
    @end()

  render : ( speechName, promptName, locals ) =>
    if typeof promptName is 'object'
      locals = promptName
      promptName = undefined

    context = merge {}, @data.sessionAttributes
    merge context, @locals
    merge context, locals

    speech name : speechName, app : @app
    .render( context ).then ( speech ) =>
      return { speech : speech } unless promptName?

      speech name : promptName, app : @app
      .render( context ).then ( prompt ) =>
        { speech : speech, prompt : prompt }

    .then ( x ) =>
      @format x.speech.format, x.prompt.format
      @send x.speech.data, x.prompt.data

  end : =>
    @out()

  toObject : =>
    merge @data.response, outputSpeech : @os().toObject()
    if @_ros?
      merge @data.response, { reprompt : { outputSpeech : @ros().toObject() } }
    @data

  os : ( val ) =>
    if arguments.length > 0
      @_os = val
      return @
    @_os = OutputSpeech.create type : @format() unless @_os?
    @_os

  ros : ( val ) =>
    if arguments.length > 0
      @_ros = val
      return @
    @_ros = OutputSpeech.create type : @repromptFormat() unless @_ros?
    @_ros

  c : ( val ) =>
    if arguments.length > 0
      @_c = val
      return @
    @_c = Card.create type : @cardFormat() unless @_c?
    @_c

  _speech : ( obj, str ) =>
    return obj.value() if arguments.length is 1
    obj.value str
    @

