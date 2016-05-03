TypedClass = require '../util/TypedClass'

module.exports = class OutputSpeech extends TypedClass
  constructor : ( {@type} )->
    @clear()

  @create : ( opt ) -> super opt, __dirname
  
    
  
  