Request = require './Request'

module.exports = class LaunchRequest extends Request

  init: =>
    @url = "/launch"
  

  