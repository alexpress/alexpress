should = require( "should" )
assert = require( "assert" )
_ = require( '../lib/util/string' )

describe "string utils", ->

  it "capitalize", ( done ) ->
    _.capitalize( "thisIsATest" ).should.equal "ThisIsATest"
    done()

  it "endsWith", ( done ) ->
    _.endsWith( "cakeBakeIntent", "Intent" ).should.equal true
    done()

  it "doesn't end with", ( done ) ->
    _.endsWith( "cakeBakeIntent", "intent" ).should.equal false
    done()

  it "trimEnd", ( done ) ->
    _.trimEnd( "cakeBakeIntent", "Intent" ).should.equal "cakeBake"
    done()


