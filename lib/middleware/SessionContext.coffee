EventEmitter = require( 'events' ).EventEmitter

module.exports = class SessionContext extends EventEmitter

  constructor : ( @req, @res ) ->
    @fields = {}
    @init()
    @req.context = @

  init : =>
    for own name, fn of @fields
      do ( name, fn ) =>
        @[ name ] = ( v ) =>
          args = [ name ]
          if arguments.length > 0
            v = fn v if fn? 
            args.push v 
          x = @res.session.apply @res, args
          return x if args.length is 1
          @emit "changed", name, args[ 1 ]
          @emit "changed:#{name}", args[ 1 ] 

        val = @req.session( name )
        @[ name ] if fn? then fn val else val

