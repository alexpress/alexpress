dot = require 'dot'
merge = require 'merge'
path = require 'path'
dfs = require './dfs'
exists = require './exists'
pfind = require './pfind'
path = require 'path'
fs = require 'fs'

exts = [ 'txt', 'ssml' ]
formats =
  ".txt" : "PlainText"
  ".ssml" : "SSML"

class Renderer

  constructor : ( {@name, @app} ) ->
    @ready = @load()
    @defs =
      cwd : @app.get "speech"
      loadfile : ( p ) ->
        fs.readFileSync path.join this.cwd, p

  load : =>
    @findTemplate()
    .then ( p ) =>
      @format = formats[ path.parse( p ).ext ]
      dfs.readFile p
    .then ( contents ) =>
      @template = dot.template contents, null, @defs

  findTemplate : =>
    base = path.join @app.get( "speech" ), @name
    ex = ( n ) -> exists "#{base}.#{n}", "File"
    test = ( v ) -> v?
    pfind exts, ex, test
    .then ( item ) =>
      throw new Error "Failed to lookup speech #{@name}" unless item?
      item

  render : ( locals ) =>
    @ready.then =>
      data = merge {}, @app.locals
      data = merge data, locals
      data : @template( data ), format : @format

renderer = ( opts ) ->
  new Renderer opts
  .render opts.context

renderer.Renderer = Renderer

module.exports = renderer