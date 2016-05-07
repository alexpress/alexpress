should = require( "should" )
assert = require( "assert" )
alexpress = require '../index'
path = require 'path'
horoscopes = require './fixtures/horoscopes'
run = require './ext/run'
should.use require './ext/ext'

app = undefined

describe "response.render", ->

  beforeEach ->
    app = alexpress()
    app.set 'speech', path.join __dirname, "speech"

  it "renders template", ( done ) ->
    app.use ( req, res, next ) ->
      res.render "wassup", { name : 'hodor' }

    run app, "horoscope", done, ( res ) ->
      res.should.have.outputSpeech "wassup hodor?"

  it "fails on missing template", ( done ) ->
    app.use ( req, res, next ) ->
      res.render "wassssssup", { name : 'hodor' }

    app.use ( err, req, res, next ) ->
      should( err instanceof Error ).equal true
      err.message.should.startWith "Failed to lookup speech"
      done()

    run app, "horoscope", done, ( res ) ->
      res.should.have.outputSpeech "wassup hodor?"

  it "missing template parameter is rendererd as 'undefined'", ( done ) ->
    app.use ( req, res, next ) ->
      res.render "wassup", { nam : 'hodor' }

    run app, "horoscope", done, ( res ) ->
      res.should.have.outputSpeech "wassup undefined?"

  it "renderAsk", ( done ) ->
    app.use ( req, res, next ) ->
      res.renderAsk "wassup", { name : 'hodor' }

    run app, "horoscope", done, ( res ) ->
      res.should.not.endSession()
      res.should.have.outputSpeech "wassup hodor?"

  it "renderTell", ( done ) ->
    app.use ( req, res, next ) ->
      res.renderTell "wassup", { name : 'hodor' }

    run app, "horoscope", done, ( res ) ->
      res.should.endSession()
      res.should.have.outputSpeech "wassup hodor?"

