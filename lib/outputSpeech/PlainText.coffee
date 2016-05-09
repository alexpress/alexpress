OutputSpeech = require './OutputSpeech'
{Throw, MissingInfoError} = require '../util/errors'

module.exports = class PlainText extends OutputSpeech

  init : => super { value : 'text' }

  isValid : => @data.text?.length > 0

