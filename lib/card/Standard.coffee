Card = require './Card'
module.exports = class Standard extends Card

  init : =>
    super
      title : 'title'
      text : 'text'

    for type in [ 'small', 'large' ]
      do ( type ) =>
        key = "#{type}ImageUrl"
        @[ key ] = ( value ) =>
          return @data[ key ] if arguments.length is 0
          @data.image = {} unless @data.image?
          @data.image[ key ] = value
          @

