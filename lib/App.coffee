Request = require './request'
Response = require './Response'
nodeifyContext = require './util/nodeify-lambda-context'

defer = setImmediate or ( fn ) -> process.nextTick fn.bind.apply( fn, arguments )

class App

  constructor : () ->
    @route = "/"
    @stack = []
    @settings =
      "speech" : "#{process.cwd()}/speech"
      "format" : "PlainText"
      'keep alive' : false

  ###
  # Returns the value of name app setting, where name is one of
  # strings in the app settings table.
  ###
  get : ( name ) => @settings[ name ]

  ###
  # Sets the value of name app setting, where name is one of
  # strings in the app settings table.
  ###
  set : ( name, value ) =>
    @settings[ name ] = value
    @

  ###
  # Utilize the given middleware `handle` to the given `route`,
  # defaulting to '/'. This "route" is the mount-point for the
  # middleware, when given a value other than '/' the middleware
  # is only effective when that segment is present in the request's
  # pathname.
  #
  # @param {String|Function|Server} route, callback or server
  # @param {Function|Server} callback or server
  # @return {Server} for chaining
  # @public
  ###
  use : ( route, fn... ) =>
    path = route
    handle = fn

    handle = handle[ 0 ] if handle.length is 1

    if Array.isArray handle
      if handle.length is 1
        handle = handle[ 0 ]
      else
        sub = new App
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
      return defer done, err if !layer

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
  # AWS Lambda Function Handler
  # http://docs.aws.amazon.com/lambda/latest/dg/nodejs-prog-model-handler.html
  #
  # @param {Object} request, Alexa request data
  # @param {Object} context, runtime information of the Lambda function that is executing.
  # @param {cb} callback, return information to the caller. 
  # @public
  ###
  lambda : ( request, context, cb ) =>
    cb = nodeifyContext context if arguments.length < 3 # pre node 4.3 runtime

    req = Request.create type : request.request.type, original : request, app : @

    out = ( err ) ->
      return cb err if err?
      cb null, res.toObject()

    res = new Response app : @, out : out
    @handle req, res, out

###*
# Invoke a route handle.
# @private
###
call = ( handle, route, err, req, res, next ) ->
  arity = handle.length
  error = err
  hasError = Boolean( err )

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
