EventEmitter = require( 'events' ).EventEmitter

module.exports = class SessionContext extends EventEmitter

  constructor : ( @req, @res ) ->
    @fields =
      name : ( v ) -> v
    @init()
    @req.context = @

  init : =>
    for own name, fn of @fields
      do ( name, fn ) =>
        @[ name ] = ( v ) =>
          args = [ name ]
          args.push fn v if arguments.length > 0
          x = @res.session.apply @res, args
          return x if args.length is 1
          @emit "changed", name, args[ 1 ]
          @emit "changed:#{name}", args[ 1 ] 

        @[ name ] fn( @req.session( name ) )

