module.exports = ( obj, opts ) ->
  opts = {} unless opts?
  name = opts.name or throw new Error( "missing option: #{name}" )
  field = opts.field or "_#{name}"
  getter = opts.getter or ()-> obj[ field ]
  setter = opts.setter or ( v )-> obj[ field ] = v

  setter opts.initial if opts.initial?

  obj[ name ] = ( value ) ->
    v = getter()
    return v if arguments.length is 0 or opts.readOnly
    if v != value
      setter value
      obj.emit "changed:#{name}", value, v if obj.emit?
    obj
