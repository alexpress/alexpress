should = require( "should" )
assert = require( "assert" )
renderer = require( '../lib/Renderer' )
alexpress = require( '../index' )
path = require 'path'

app = alexpress()
app.set "speech", path.join __dirname, "fixtures/speech"

gettysburg = "Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal."

describe "Speech", ->

  it "load a template", ( done ) ->
    locals = when : "Four score and seven years", what : "Liberty"

    renderer name : "gettysburg", app : app, context : locals
    .then ( x ) ->
      x.format.should.equal 'PlainText'
      x.data.should.equal gettysburg
      done()


