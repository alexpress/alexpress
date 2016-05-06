should = require( "should" )
assert = require( "assert" )
alexpress = require '../index'
path = require 'path'
horoscopes = require './fixtures/horoscopes'

request = ( name ) -> require path.join __dirname, "fixtures", "request", "#{name}.json"
app = undefined
context = {}

should.use require './ext/ext'

sessionStaysActive = ( res ) -> res.response.shouldEndSession.should.equal false
sessionEnds = ( res ) -> res.response.shouldEndSession.should.equal true
formatIs = ( res, format ) -> res.response.outputSpeech.type.should.equal format

run = ( name, done, fn ) ->
  app.lambda request( name ), context, ( err, res ) ->
    return done err if err?
    fn res
    done()

describe "alexpress", ->

  beforeEach -> app = alexpress()

  describe "defaults", ->
    it "don't keep session active", ( done ) ->
      run "horoscope", done, ( res ) ->
        res.version.should.equal "1.0"
        res.should.endSession()
        sessionEnds res

  describe "app", ->

    it "get/set", ->
      should.not.exist app.get 'test'

    it "get/set", ->
      assert app.get( 'format' ), 'PlainText'

    it "get/set", ->
      app.set 'format', 'SSML'
      assert app.get( 'format' ), 'SSML'

    it "keep alive", ( done ) ->
      app.set 'keep alive', true

      run "horoscope", done, ( res ) ->
        res.should.not.endSession()

  describe "speech output", ->

    it "default speech format is PlainText", ( done ) ->
      app.use "/launch", ( req, res, next ) -> res.send "test"

      run "launch", done, ( res ) ->
        res.should.have.outputSpeechFormat 'PlainText'
        .and.outputSpeech 'test'

    it "set speech output format to SSML", ( done ) ->
      str = "<speak>Let's get started</speak>"
      app.set "format", "SSML"

      app.use "/launch", ( req, res, next ) -> res.send str

      run "launch", done, ( res ) ->
        res.should.have.outputSpeechFormat 'SSML'
        .and.outputSpeech str

    it "reprompt", ( done ) ->
      app.set "json spaces", 2
      app.use "/intent/amazon/help", ( req, res, next ) ->
        res.ask "a", "b"

      run "help", done, ( res ) ->
        res.should.have.repromptSpeech "b"
        .and.outputSpeech "a"

    it "reprompt inline", ( done ) ->
      app.set "json spaces", 2
      app.use "/intent/amazon/help", ( req, res, next ) ->
        res.ask [ "a", "b" ]

      run "help", done, ( res ) ->
        res.should.have.repromptSpeech "b"
        .and.outputSpeech "a"

    it "`tell` closes the session", ( done ) ->
      app.use ( req, res, next ) -> res.tell "bye"

      run "horoscope", done, ( res ) ->
        res.should.endSession()

    it "`ask` keeps the session alive", ( done ) ->
      app.use ( req, res, next ) -> res.ask "wassup?"

      run "horoscope", done, ( res ) ->
        res.should.not.endSession()

  describe "middleware", ->
    it "for LaunchRequest", ( done ) ->
      str = "Let's get started"
      app.use "/launch", ( req, res, next ) ->
        req.should.be.newSession()
        req.type.should.equal "LaunchRequest"
        req.timestamp.should.equal "2015-05-13T12:34:56Z"
        req.requestId.should.equal "amzn1.echo-api.request.0000000-0000-0000-0000-00000000000"
        req.userId.should.equal "amzn1.account.AM3B00000000000000000000000"
        req.userAccessToken.should.equal "280402837082975087508s0d8f7as08f70a9s87f9"
        req.sessionId.should.equal "amzn1.echo-api.session.0000000-0000-0000-0000-00000000000"
        req.applicationId.should.equal "amzn1.echo-sdk-ams.app.000000-d0ed-0000-ad00-000000d00ebe"
        req.session( "test" ).should.equal 123

        res.send str

      run "launch", done, ( res ) ->
        res.should.have.outputSpeechFormat 'PlainText'
        .and.outputSpeech str

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

      run "horoscope", done, ( res ) ->
        res.sessionAttributes.supportedHoroscopePeriods.daily.should.equal true
        res.response.outputSpeech.text.should.equal horoscopes.virgo
        res.response.shouldEndSession.should.equal false

    it "for session ended", ( done ) ->
      app.use "/sessionEnded", ( req, res, next ) ->
        req.reason.should.equal "USER_INITIATED"
        res.send "done"

      run "sessionEnded", done, ( res ) ->

    it "for built-in intents", ( done ) ->
      app.use "/intent/amazon/help", ( req, res, next ) ->
        res.ask "wassup?"

      run "help", done, ( res ) ->
        res.response.outputSpeech.text.should.equal "wassup?"

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

      run "horoscope", done, ( res ) ->
        res.response.outputSpeech.text.should.equal "1 2 3"

  describe "handle errors", ->
    it "in the callback", ( done ) ->
      app.use ( req, res, next ) ->
        throw new Error( "test" )

      app.lambda request( "horoscope" ), context, ( err, res ) ->
        should( err instanceof Error ).equal true
        done()

    it "in middleware", ( done ) ->
      app.use ( req, res, next ) ->
        throw new Error( "test" )

      app.use ( err, req, res, next ) ->
        err.message.should.equal "test"
        done()

      app.lambda request( "horoscope" ), context, ( err, res ) ->
        should( err instanceof Error ).equal true
        done()

  describe "session", ->

    it "keep session alive", ( done ) ->
      app.use "/intent/amazon/help", ( req, res, next ) ->
        res.keepAlive true
        .ask "wassup?"

      run "help", done, ( res ) ->
        res.response.shouldEndSession.should.equal false

    it "set session attributes", ( done ) ->
      app.use "/intent/amazon/help", ( req, res, next ) ->
        res.session "abraca", "dabra"
        .ask "wassup?"

      run "help", done, ( res ) ->
        res.sessionAttributes.abraca.should.equal "dabra"

  describe "cards", ->

    it "simple card", ( done ) ->
      app.use ( req, res, next ) ->
        res.simpleCard "my title", "my content"
        .send()

      run "horoscope", done, ( res ) ->
        res.response.card.type.should.equal 'Simple'
        res.response.card.title.should.equal 'my title'
        res.response.card.content.should.equal 'my content'
        should.not.exist res.response.card.text

    it "standard card", ( done ) ->
      app.use ( req, res, next ) ->
        res.standardCard "my title", "my text", "smallurl", "bigurl"
        .send()

      run "horoscope", done, ( res ) ->
        res.response.card.type.should.equal 'Standard'
        res.response.card.title.should.equal 'my title'
        res.response.card.text.should.equal 'my text'
        res.response.card.image.smallImageUrl.should.equal 'smallurl'
        res.response.card.image.largeImageUrl.should.equal 'bigurl'
        should.not.exist res.response.card.content

    it "link account card", ( done ) ->
      app.use ( req, res, next ) ->
        res.linkAccountCard().send()

      run "horoscope", done, ( res ) ->
        should.not.exist res.response.card.title
        should.not.exist res.response.card.content
        should.not.exist res.response.card.text
        res.should.endSession()


