TypedClass = require './TypedClass'

module.exports = class BaseObject extends TypedClass

  constructor : ( {@type} )->
    @data = { type : @type }
    @init()

  init : ( props ) =>
    for own alias, field of props
      do ( alias, field ) =>
        @[ alias ] = ( value ) =>
          return @data[ field ] if arguments.length is 0
          @data[ field ] = value
          @

  isValid : -> true

  toObject : =>
    @data

