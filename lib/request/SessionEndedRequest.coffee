Request = require './Request'

module.exports = class SessionEndedRequest extends Request

  init : =>
    @reason = @original.request.reason
    @url = "/sessionEnded"
  
    
  
  