ssml = require( '../util/ssml' )
OutputSpeech = require './OutputSpeech'

module.exports = class SSML extends OutputSpeech
  constructor : ( opts = {} ) ->
    super opts
    @append opts.ssml if opts.ssml?

  clear : =>
    @ssml = ""

  append : ( str ) =>
    @ssml = ssml.fromStr str, @ssml


  
  