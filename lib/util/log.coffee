replacer = ( k, v ) ->
  return '[Function]' if typeof v is 'function'
  v

module.exports = ( tag ) -> ( items... ) ->
  msgs = for item in items
    if typeof item is 'object' then JSON.stringify item, replacer else item

  console.log "[#{tag}] #{msgs.join ' '}"