module.exports = ( req, res, next ) ->
  res.session( req.sessionAttributes )
  next()
