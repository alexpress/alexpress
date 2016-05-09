TypedError = require 'error/typed'

MissingInfoError = TypedError
  type : 'missingInfo'
  message : "The following information is missing: {name}"
  name : undefined

Throw = ( what ) ->
  if : ( x ) -> throw what if x
  unless : ( x )  -> throw what unless x
    
module.exports =
  Throw : Throw
  MissingInfoError : MissingInfoError