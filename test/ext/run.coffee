path = require 'path'
log = require( '../../lib/util/log' ) 'test'
session = {}
context = {}
merge = ( target, src ) -> target[ k ] = v for own k,v of src

request = ( name ) -> require path.join __dirname, "../fixtures", "request", "#{name}.json"

run = ( app, name, done, fn ) ->
  r = request name
  merge r.session.attributes, session unless r.session.new

  app.run r, ( err, res ) ->
    return done err if err?
    merge session, res.sessionAttributes
    fn res if fn?
    done()

module.exports = run