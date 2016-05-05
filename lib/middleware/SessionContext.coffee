EventEmitter = require( 'events' ).EventEmitter

module.exports = class SessionContext extends EventEmitter

  constructor : ( @req, @res ) ->
    @cache = {}
    @fields = {}
    @init()
    @req.context = @

  init : ( fields ) =>
    @fields[ k ] = v for own k,v of fields if typeof fields is 'object'

    for own name, fn of @fields
      do ( name, fn ) =>
        fn = fn.convert if typeof fn is 'object'

        @[ name ] = ( v ) =>
          return @cache[ name ] if arguments.length is 0
          oldVal = @cache[ name ]
          v = if fn? then fn( v ) else v
          return if v is oldVal
          @cache[ name ] = v
          @res.session name, v
          @emit "changed", name, v, oldVal
          @emit "changed:#{name}", v, oldVal

        val = @req.session( name )
        @[ name ] if fn? then fn val else val

  clear : =>
    for own name, fn of @fields
      do ( name, fn ) =>
        initial = fn.initial if typeof fn is 'object'
        @[ name ] initial

