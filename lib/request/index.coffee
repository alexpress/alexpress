Request = require "./Request"

request = ( opts ) ->
  Request.create opts

request.Request = Request

module.exports = request