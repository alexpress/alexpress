module.exports = ( ctx ) -> ( err, res ) ->
  h = if ctx.done? then [ ctx.done, ctx.done ] else [ ctx.fail, ctx.succeed ]
  x = if err? then [ 0, err ] else [ 1, res ]
  h[ x[ 0 ] ] x[ 1 ]
