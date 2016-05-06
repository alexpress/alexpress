field =
  PlainText : 'text'
  SSML : 'ssml'

module.exports = ( should, Assertion ) ->

  Assertion.add 'newSession', ->
    @params = { operator : "session to be new" }
    @obj.new.should.equal true

  Assertion.add 'outputSpeechFormat', ( format ) ->
    @params = { operator : "outputSpeech format to be #{format}" }
    @obj.response.outputSpeech.type.should.equal format

  Assertion.add 'outputSpeech', ( str ) ->
    @params = { operator : "outputSpeech to be #{str}" }
    os = @obj.response.outputSpeech
    should.exist os[ field[ os.type ] ]
    os[ field[ os.type ] ].should.equal str

  Assertion.add 'repromptSpeech', ( str ) ->
    @params = { operator : "repromptSpeech to be #{str}" }
    should.exist @obj.response.reprompt
    os = @obj.response.reprompt.outputSpeech
    should.exist os[ field[ os.type ] ]
    os[ field[ os.type ] ].should.equal str

  Assertion.add 'repromptFormat', ( format ) ->
    @params = { operator : "reprompt format to be #{format}" }
    @obj.response.reprompt.outputSpeech.type.should.equal format

  Assertion.add 'endSession', ->
    @params = { operator : 'shouldEndSession to be true' }
    @obj.response.shouldEndSession.should.equal true

