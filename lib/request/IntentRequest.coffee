Request = require './Request'
_ = require '../util/string'

module.exports = class IntentRequest extends Request

  init : =>
    @name = _.trimEnd @original.request.intent.name, "Intent"
    @name = @name.replace "AMAZON.", "amazon/"
    @url = "/intent/#{@name}"

  slot: (name) =>
    return unless @original.request.intent.slots?
    @original.request.intent.slots[name]?.value

    
  
  