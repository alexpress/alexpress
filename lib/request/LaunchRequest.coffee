Request = require './Request'

module.exports = class LaunchRequest extends Request

  constructor : ( opts ) ->
    super opts
    @url = "/launch"
  

  
  