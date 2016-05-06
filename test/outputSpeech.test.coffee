should = require( "should" )
assert = require( "assert" )
OutputSpeech = require( '../lib/outputSpeech' )
path = require 'path'

describe "OutputSpeech", ->

  os = undefined
  
  describe "PlainText", ->

    beforeEach ->
      os = OutputSpeech.create type : 'PlainText'

    it "sets type field", ( done ) ->
      obj = os.toObject()
      obj.type.should.equal 'PlainText'
      done()

    it "sets text field", ( done ) ->
      os.value "test"
      obj = os.toObject()
      obj.text.should.equal 'test'
      should(obj.ssml).equal undefined
      done()

  describe "SSML", ->

    beforeEach ->
      os = OutputSpeech.create type : 'SSML'

    it "sets type field", ( done ) ->
      obj = os.toObject()
      obj.type.should.equal 'SSML'
      done()

    it "sets ssml field", ( done ) ->
      os.value "test"
      obj = os.toObject()
      obj.ssml.should.equal 'test'
      should(obj.text).equal undefined
      done()


