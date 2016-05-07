BaseObject = require '../util/BaseObject'

module.exports = class OutputSpeech extends BaseObject

  constructor : ( opts = {} )->
    super opts
    @value opts.value if opts.value?

  @create : ( opt ) -> super opt, __dirname
    
  
  