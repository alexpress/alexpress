OutputSpeech = require './OutputSpeech'

module.exports = class SSML extends OutputSpeech

  init : =>
    super { value : 'ssml' }
  
  