TypedClass = require '../util/TypedClass'

module.exports = class OutputSpeech extends TypedClass
  constructor : ( {@type} )->
    @clear()

  isSSML : => @type is "SSML"

  isPlainText : => @type is "PlainText"

  @create : ( opt ) -> super opt, __dirname
  
    
  
  