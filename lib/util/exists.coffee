dfs = require './dfs'

module.exports = ( path, type ) ->
  dfs.stat path
  .then ( stat ) ->
    return path unless type?
    if type in [ 'File', 'Directory', 'Socket', 'BlockDevice', 'CharacterDevice', 'SymbolicLink', 'FIFO' ]
      return path if stat[ "is#{type}" ]()
    throw new Error "bad type: #{type}"
  .catch ( e ) ->
    return if e.code is "ENOENT" #  No such file or directory
    throw e
