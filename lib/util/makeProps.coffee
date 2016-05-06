module.exports = ( obj, props ) ->
  for name of props
    do ( name ) ->
      field = "_#{name}"
      obj[ name ] = ( value ) ->
        old = obj[ field ]
        return old if arguments.length is 0
        if old != value
          obj[ field ] = value
          obj.emit "changed:#{name}", value, old if obj.emit?
        obj
