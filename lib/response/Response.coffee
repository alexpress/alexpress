Promise = require 'bluebird'
OutputSpeech = require '../outputSpeech/index'
Card = require '../card/index'
renderer = require '../util/renderer'
merge = require 'merge'
EventEmitter = require( 'events' ).EventEmitter
prop = require '../util/prop'
log = require( '../util/log' ) 'Response'

module.exports = class Response extends EventEmitter

  constructor : ( opts = {} ) ->
    @locals = {}
    @tasks = []

    @data =
      version : "1.0"
      sessionAttributes : {}
      response : {}

    for o in [ "app", "out" ]
      @[ o ] = opts[ o ] or throw new Error ("missing option: #{o}")

    @req = @app.req

    format = @app.get "format"

    prop @, name : "format", initial : format
    prop @, name : "repromptFormat", initial : format
    prop @, name : "version", initial : @data.version, readOnly : true
    prop @, name : "card"
    prop @, name : "speech"
    prop @, name : "reprompt"

    prop @,
      name : "keepAlive"
      initial : @app.get( 'keep alive' )
      getter : => !@data.response.shouldEndSession
      setter : ( v ) => @data.response.shouldEndSession = !v

  local : ( name, value ) =>
    return @locals[ name ] if arguments.length < 2
    @locals[ name ] = value
    @

  session : ( name, value ) =>
    sa = @data.sessionAttributes
    if arguments.length is 2
      sa[ name ] = value
      return @

    t = typeof name
    return sa if t is 'undefined'
    return sa[ k ] = v for own k,v of name if t is 'object'
    sa[ name ]

  simpleCard : ( title, content ) =>
    @card( Card.create type : "Simple"
      .title title
      .content content
    )

  standardCard : ( title, text, smallImageUrl, largeImageUrl ) =>
    @card( Card.create type : "Standard"
      .title title
      .text text
      .smallImageUrl smallImageUrl
      .largeImageUrl largeImageUrl
    )

  linkAccountCard : () =>
    @card Card.create type : "LinkAccount"
    .keepAlive false # user must use app for account linking

  renderSimpleCard : ( title, content, locals ) =>
    @tasks.push( @doRender content, locals
    .then ( x ) =>
      @simpleCard title, x.data )
    @

  renderStandardCard : ( title, text, smallImageUrl, largeImageUrl, locals ) =>
    if typeof smallImageUrl is 'object'
      locals = smallImageUrl
      smallImageUrl = largeImageUrl = undefined
    if typeof largemageUrl is 'object'
      locals = largeImageUrl
      largeImageUrl = undefined

    @tasks.push( @doRender text, locals
    .then ( x ) =>
      @standardCard title, x.data, smallImageUrl, largeImageUrl )
    @

  ask : ( speech, prompt ) => @keepAlive( true ).send speech, prompt

  renderAsk : ( speech, prompt, locals ) => @keepAlive( true ).render speech, prompt, locals

  tell : ( speech, prompt ) => @keepAlive( false ).send speech, prompt

  renderTell : ( speech, prompt, locals ) => @keepAlive( false ).render speech, prompt, locals

  ssml : ( speech, prompt ) => @format( "SSML" ).send speech, prompt

  plainText : ( speech, prompt ) => @format( "PlainText" ).send speech, prompt

  renderReprompt : ( promptName, locals ) =>
    @tasks.push( @doRender promptName, locals
    .then ( prompt ) =>
      @reprompt prompt.data, prompt.format )
    @

  send : ( speech, prompt ) =>
    @reprompt prompt if prompt?
    @speech speech if speech?
    @end()

  render : ( speechName, promptName, locals ) =>
    if typeof promptName is 'object'
      locals = promptName
      promptName = undefined

    @renderReprompt promptName, locals if promptName?

    @doRender speechName, locals
    .then ( speech ) =>
      @format speech.format
      .send speech.data

  end : =>
    Promise
    .all @tasks
    .asCallback ( err ) =>
      @out err


  toObject : =>
    data = merge {}, @data
    os = OutputSpeech.create type : @format(), value : @speech()
    merge data.response, outputSpeech : os.toObject() if os.isValid()

    if @reprompt()
      ros = OutputSpeech.create type : @repromptFormat(), value : @reprompt()
      merge data.response, { reprompt : { outputSpeech : ros.toObject() } }

    merge data.response, card : @card().toObject() if @card()?

    data

  doRender : ( template, locals ) =>
    context = merge {}, @data.sessionAttributes
    merge context, @locals
    merge context, locals
    renderer name : template, app : @app, context : context
    .catch ( err ) =>
      @req.next err
      Promise.reject err

