# based on https://github.com/jaredhanson/utils-merge
module.exports = ( a, b ) ->
  if a? and b?
    for own k, v of b
      a[ k ] = v
  a