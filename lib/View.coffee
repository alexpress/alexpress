'use strict'
path = require( 'path' )
fs = require( 'fs' )

dirname = path.dirname
basename = path.basename
extname = path.extname
join = path.join
resolve = path.resolve

###*
# Return a stat, maybe.
#
# @param {string} path
# @return {fs.Stats}
# @private
###
tryStat = ( path ) ->
  try
    return fs.statSync( path )
  catch e


###*
# Initialize a new `View` with the given `name`.
#
# Options:
#
#   - `defaultEngine` the default template engine name
#   - `engines` template engine require() cache
#   - `root` root path for view lookup
#
# @param {string} name
# @param {object} options
# @public
###

class View
  constructor : ( name, opts = {} ) ->
    @defaultEngine = opts.defaultEngine
    @ext = extname( name )
    @name = name
    @root = opts.root

    if !@ext and !@defaultEngine
      throw new Error( 'No default engine was specified and no extension was provided.' )

    fileName = name
    if !@ext
      # get extension from default engine name
      @ext = if @defaultEngine[ 0 ] != '.' then '.' + @defaultEngine else @defaultEngine
      fileName += @ext

    if !opts.engines[ @ext ]
      # load engine
      opts.engines[ @ext ] = require( @ext.substr( 1 ) ).__express

    # store loaded engine
    @engine = opts.engines[ @ext ]

    # lookup path
    @path = @lookup( fileName )

  ###*
  # Lookup view by the given `name`
  #
  # @param {string} name
  # @private
  ###

  lookup : ( name ) =>
    p = undefined
    roots = [].concat( @root )
    while i < roots.length and !p
      root = roots[ i ]
      # resolve the path
      loc = resolve( root, name )
      dir = dirname( loc )
      file = basename( loc )
      # resolve the file
      p = @resolve( dir, file )
      i++
    p

  ###*
  # Render with the given options.
  #
  # @param {object} options
  # @param {function} callback
  # @private
  ###
  render : ( options, callback ) =>
    @engine @path, options, callback

  ###*
  # Resolve the file within the given directory.
  #
  # @param {string} dir
  # @param {string} file
  # @private
  ###
  resolve : ( dir, file ) =>
    ext = @ext

    # <path>.<ext>
    p = join( dir, file )
    stat = tryStat( p )
    return p if stat and stat.isFile()

    # <path>/index.<ext>
    p = join( dir, basename( file, ext ), 'index' + ext )
    stat = tryStat( path )
    return p if stat and stat.isFile()

module.exports = View
