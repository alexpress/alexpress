OutputSpeech = require './OutputSpeech'

module.exports = class PlainText extends OutputSpeech
  constructor : ( opts = {} ) ->
    super opts
    @append opts.text if opts.text?

  clear : => @text = ""

  append : ( str ) =>
    @text += str


  
  