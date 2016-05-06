Response = require "./Response"

response = ( opts ) ->
  new Response opts

response.Response = Response

module.exports = response