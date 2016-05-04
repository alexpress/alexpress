should = require( "should" )
assert = require( "assert" )
{App, persistSession, SessionContext}= require( '../index' )
path = require 'path'
horoscopes = require './fixtures/horoscopes'

txt = ( name ) -> require path.join __dirname, "fixtures", "text", "#{name}.txt"
request = ( name ) -> require path.join __dirname, "fixtures", "request", "#{name}.json"

class Ctx extends SessionContext
  init : =>
    @fields =
      name : undefined
    super()

app = undefined

describe "intent schema", ->

  beforeEach ->
    app = new App "log group" : "group", "log stream" : "stream"

  describe "defaults", ->

    it "default output without middleware", ( done ) ->
      app.handler request( "horoscope" ), {}, ( err, res ) ->
        return done err if err?
        res.version.should.equal "1.0"
        done()

    it "close the session", ( done ) ->
      app.handler request( "horoscope" ), null, ( err, res ) ->
        return done err if err?
        res.response.shouldEndSession.should.equal true
        done()

  describe "output", ->

    it "default speech format is PlainText", ( done ) ->
      app.use "/launch", ( req, res, next ) -> res.send "test"

      app.handler request( "launch" ), null, ( err, res ) ->
        return done err if err?
        res.response.outputSpeech.type.should.equal "PlainText"
        res.response.outputSpeech.text.should.equal "test"
        done()

    it "set speech output format to SSML", ( done ) ->
      str = "Let's get started"
      app.set "format", "SSML"

      app.use "/launch", ( req, res, next ) -> res.send str

      app.handler request( "launch" ), null, ( err, res ) ->
        return done err if err?

        res.response.outputSpeech.type.should.equal "SSML"
        res.response.outputSpeech.ssml.should.equal "<speak>#{str}</speak>"
        done()

    it "reprompt", ( done ) ->
      app.set "json spaces", 2
      app.use "/intent/amazon/help", ( req, res, next ) ->
        res
        .reprompt "b"
        .ask "a"

      app.handler request( "help" ), null, ( err, res ) ->
        return done err if err?
        res.response.reprompt.outputSpeech.text.should.equal "b"
        res.response.outputSpeech.text.should.equal "a"
        done()

    it "reprompt inline", ( done ) ->
      app.set "json spaces", 2
      app.use "/intent/amazon/help", ( req, res, next ) ->
        res.ask [ "a", "b" ]

      app.handler request( "help" ), null, ( err, res ) ->
        return done err if err?

        res.response.reprompt.outputSpeech.text.should.equal "b"
        res.response.outputSpeech.text.should.equal "a"
        done()

    it "`tell` closes the session", ( done ) ->
      app.use ( req, res, next ) -> res.tell "bye"

      app.handler request( "horoscope" ), null, ( err, res ) ->
        return done err if err?

        res.response.shouldEndSession.should.equal true
        done()

    it "`ask` keeps the session alive", ( done ) ->
      app.use ( req, res, next ) -> res.ask "wassup?"

      app.handler request( "horoscope" ), null, ( err, res ) ->
        return done err if err?

        res.response.shouldEndSession.should.equal false
        done()

  describe "middleware", ->
    it "for LaunchRequest", ( done ) ->
      str = "Let's get started"
      app.use "/launch", ( req, res, next ) ->
        req.new.should.equal true
        req.type.should.equal "LaunchRequest"
        req.timestamp.should.equal "2015-05-13T12:34:56Z"
        req.requestId.should.equal "amzn1.echo-api.request.0000000-0000-0000-0000-00000000000"
        req.userId.should.equal "amzn1.account.AM3B00000000000000000000000"
        req.userAccessToken.should.equal "280402837082975087508s0d8f7as08f70a9s87f9"
        req.sessionId.should.equal "amzn1.echo-api.session.0000000-0000-0000-0000-00000000000"
        req.applicationId.should.equal "amzn1.echo-sdk-ams.app.000000-d0ed-0000-ad00-000000d00ebe"
        req.session( "test" ).should.equal 123

        res.send str

      app.handler request( "launch" ), null, ( err, res ) ->
        return done err if err?

        res.response.outputSpeech.type.should.equal "PlainText"
        res.response.outputSpeech.text.should.equal str
        done()

    it "for intents", ( done ) ->
      app.use "/intent/GetZodiacHoroscope", ( req, res, next ) ->
        supported = req.session( "supportedHoroscopePeriods" )
        supported.daily.should.equal true
        res.session "supportedHoroscopePeriods", supported
        sign = req.slot( "ZodiacSign" )
        sign.should.equal "virgo"
        res
        .keepAlive true
        .send horoscopes[ sign ]

      app.handler request( "horoscope" ), null, ( err, res ) ->
        return done err if err?

        res.sessionAttributes.supportedHoroscopePeriods.daily.should.equal true
        res.response.outputSpeech.text.should.equal horoscopes.virgo
        res.response.shouldEndSession.should.equal false
        done()

    it "for session ended", ( done ) ->
      app.use "/sessionEnded", ( req, res, next ) ->
        req.reason.should.equal "USER_INITIATED"
        res.send "done"

      app.handler request( "sessionEnded" ), null, ( err, res ) ->
        return done err if err?
        done()

    it "for built-in intents", ( done ) ->
      app.use "/intent/amazon/help", ( req, res, next ) ->
        res.ask "wassup?"

      app.handler request( "help" ), null, ( err, res ) ->
        return done err if err?

        res.response.outputSpeech.text.should.equal "wassup?"
        done()

    it "multiple middleware for a route", ( done ) ->
      h1 = ( req, res, next ) ->
        req.output.push 1
        next()

      h2 = ( req, res, next ) ->
        req.output.push 2
        next()

      h3 = ( req, res, next ) ->
        req.output.push 3
        next()

      app.use ( req, res, next ) ->
        req.output = []
        next()

      app.use "/intent/GetZodiacHoroscope", h1, h2, h3

      app.use ( req, res, next ) ->
        res.tell req.output.join " "

      app.handler request( "horoscope" ), null, ( err, res ) ->
        return done err if err?

        res.response.outputSpeech.text.should.equal "1 2 3"
        done()

    it "persist session attributes", ( done ) ->
      app.use persistSession

      app.use "/launch", ( req, res, next ) ->
        res.ask "wassup?"

      app.handler request( "launch" ), null, ( err, res ) ->
        return done err if err?
        res.sessionAttributes.test.should.equal 123
        done()

  describe "handle errors", ->
    it "in the callback", ( done ) ->
      app.use ( req, res, next ) ->
        throw new Error( "test" )

      app.handler request( "horoscope" ), null, ( err, res ) ->
        err.message.should.equal "test"
        done()

    it "in middleware", ( done ) ->
      app.use ( req, res, next ) ->
        throw new Error( "test" )

      app.use ( err, req, res, next ) ->
        err.message.should.equal "test"
        done()

      app.handler request( "horoscope" ), null, ( err, res ) ->

  describe "session", ->

    it "keep session alive", ( done ) ->
      app.use "/intent/amazon/help", ( req, res, next ) ->
        res.keepAlive true
        .ask "wassup?"

      app.handler request( "help" ), null, ( err, res ) ->
        return done err if err?

        res.response.shouldEndSession.should.equal false
        done()

    it "set session attributes", ( done ) ->
      app.use "/intent/amazon/help", ( req, res, next ) ->
        res.session "abraca", "dabra"
        .ask "wassup?"

      app.handler request( "help" ), null, ( err, res ) ->
        return done err if err?
        res.sessionAttributes.abraca.should.equal "dabra"
        done()

  describe "context", ->
    it "attach session context object", ( done ) ->
      app.use ( req, res, next ) ->
        new Ctx req, res
        next()

      app.use "/intent/amazon/help", ( req, res, next ) ->
        req.context.name "test"
        res.ask "wassup?"

      app.handler request( "help" ), null, ( err, res ) ->
        return done err if err?
        res.sessionAttributes.name.should.equal "test"
        done()

  describe "context", ->



