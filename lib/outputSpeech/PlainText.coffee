OutputSpeech = require './OutputSpeech'

module.exports = class PlainText extends OutputSpeech

  init : =>
    super { value : 'text' }  
  