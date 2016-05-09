dfs = require './dfs'

ALLOWED_TYPES = [ 'File', 'Directory', 'Socket',
  'BlockDevice', 'CharacterDevice', 'SymbolicLink', 'FIFO' ]

module.exports = ( path, type ) ->
  dfs.stat path
  .then ( stat ) ->
    return path unless type?
    if type in ALLOWED_TYPES
      return path if stat[ "is#{type}" ]()
    throw new Error "bad type: #{type}"
  .catch ( e ) ->
    return if e.code is "ENOENT" #  No such file or directory
    throw e
