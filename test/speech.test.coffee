should = require( "should" )
assert = require( "assert" )
Speech = require( '../lib/Speech' )
{App}= require( '../index' )
path = require 'path'

app = new App
app.set "speech", path.join __dirname, "fixtures/speech"

gettysburg = "Four score and seven years ago our fathers brought forth on this continent, a new nation, conceived in Liberty, and dedicated to the proposition that all men are created equal."

describe "Speech", ->

  it "load a template", ( done ) ->
    s = new Speech name : "gettysburg", app : app
    s.render when : "Four score and seven years", what : "Liberty"
    .then (txt) ->
      s.format.should.equal 'PlainText'
      txt.should.equal gettysburg
      done()


