'use strict'
Request = require './request'
Response = require './response/Response'
View = require './View'

### istanbul ignore next ###
defer = if typeof setImmediate == 'function' then setImmediate else (( fn ) ->
  process.nextTick fn.bind.apply( fn, arguments )
)

class App
  constructor : ( opts = {} ) ->
    @route = "/"
    @stack = []
    @cache = {}
    @parent = opts.parent or null
    @settings =
      views : "#{process.cwd()}/views"
      "format" : "PlainText"
      "json spaces" : opts["json spaces"] or null
      "json replacer" : null
      "persist session" : true

  ###
  # Returns the value of name app setting, where name is one of
  # strings in the app settings table.
  ###
  get : ( name ) => @settings[ name ]

  ###
  # Sets the value of name app setting, where name is one of
  # strings in the app settings table.
  ###
  set : ( name, value ) => @settings[ name ] = value

  ###
  # Utilize the given middleware `handle` to the given `route`,
  # defaulting to _/_. This "route" is the mount-point for the
  # middleware, when given a value other than _/_ the middleware
  # is only effective when that segment is present in the request's
  # pathname.
  #
  # For example if we were to mount a function at _/admin_, it would
  # be invoked on _/admin_, and _/admin/settings_, however it would
  # not be invoked for _/_, or _/posts_.
  #
  # @param {String|Function|Server} route, callback or server
  # @param {Function|Server} callback or server
  # @return {Server} for chaining
  # @public
  ###
  use : ( route, fn... ) =>
    path = route
    handle = fn

    if handle.length is 1
      handle = handle[ 0 ]

    if Array.isArray handle
      if handle.length is 1
        handle = handle[ 0 ]
      else
        sub = new App parent : @
        sub.use h for h in handle
        handle = sub

    # default route to '/'
    if typeof route != 'string'
      handle = route
      path = '/'

    # wrap sub-apps
    if typeof handle.handle == 'function'
      server = handle
      server.route = path

      handle = ( req, res, next ) ->
        server.handle req, res, next

    # strip trailing slash
    path = path.slice( 0, -1 ) if path[ path.length - 1 ] == '/'

    # add the middleware
    #  debug 'use %s %s', path or '/', handle.name or 'anonymous'
    @stack.push
      route : path
      handle : handle
    @

  ###
  # Handle server requests, punting them down
  # the middleware stack.
  #
  # @private
  ###
  handle : ( req, res, out ) =>
    index = 0
    protohost = ''
    removed = ''
    slashAdded = false
    stack = @stack

    # final function handler
    done = out

    next = ( err ) ->
      if slashAdded
        req.url = req.url.substr( 1 )
        slashAdded = false

      if removed.length != 0
        req.url = protohost + removed + req.url.substr( protohost.length )
        removed = ''

      # next callback
      layer = stack[ index++ ]

      # all done
      if !layer
        defer done, err
        return

      # route data
      #    path = parseUrl( req ).pathname or '/'
      path = req.url or '/'
      route = layer.route

      # skip this layer if the route doesn't match
      return next( err ) if path.toLowerCase().substr( 0, route.length ) != route.toLowerCase()

      # skip if route match does not border "/", ".", or end
      c = path[ route.length ]
      return next( err ) if c != undefined and '/' != c and '.' != c

      # trim off the part of the url that matches the route
      if route.length != 0 and route != '/'
        removed = route
        req.url = protohost + req.url.substr( protohost.length + removed.length )
        # ensure leading slash
        if !protohost and req.url[ 0 ] != '/'
          req.url = '/' + req.url
          slashAdded = true

      # call the layer handle
      call layer.handle, route, err, req, res, next

    req.originalUrl = req.originalUrl or req.url
    next()

  ###
  # aws lambda handler
  #
  ###

  handler : ( event, context, cb ) =>
    throw new Error( "Old format not supported. Use with node 4.4" ) unless arguments.length is 3

    req = Request.create type : event.request.type, original : event
    req.app = @

    replacer = @get "json replacer"
    spaces = @get "json spaces"
    out = ( err ) ->
      return cb err if err?
      cb null, JSON.stringify res.data, replacer, spaces

    res = new Response out : out, app : @, req : req
    @handle req, res, out

  render : ( name, options, callback ) =>
    cache = @cache
    done = callback
    engines = @engines
    opts = options
    renderOptions = {}
    view = undefined

    # support callback function as second arg
    if typeof options == 'function'
      done = options
      opts = {}

    # merge app.locals
    merge renderOptions, @locals

    # merge options._locals
    if opts._locals
      merge renderOptions, opts._locals

    # merge options
    merge renderOptions, opts

    view = new View( name,
      defaultEngine : @get( 'view engine' )
      root : @get( 'views' )
      engines : engines )

    if !view.path
      dirs = if Array.isArray( view.root ) and view.root.length > 1 then 'directories "' + view.root.slice( 0, -1 ).join( '", "' ) + '" or "' + view.root[ view.root.length - 1 ] + '"' else 'directory "' + view.root + '"'
      err = new Error( 'Failed to lookup view "' + name + '" in views ' + dirs )
      err.view = view
      return done( err )

    tryRender view, renderOptions, done

###*
# Invoke a route handle.
# @private
###
call = ( handle, route, err, req, res, next ) ->
  arity = handle.length
  error = err
  hasError = Boolean( err )
  #  debug '%s %s : %s', handle.name or '<anonymous>', route, req.originalUrl

  req.next = next
  try
  # error-handling middleware
    return handle err, req, res, next if hasError and arity == 4

    # request-handling middleware
    return handle req, res, next if !hasError and arity < 4
  catch e
  # replace the error
    error = e

  # continue
  next error

module.exports = App
