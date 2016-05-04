Promise = require 'bluebird'
fs = require 'fs'

methods = [ "access", "appendFile", "chmod", "chown", "fchmod", "fchown", "fdatasync", "fstat",
  "fsync", "ftruncate", "futimes", "lchmod", "lchown", "link", "lstat", "mkdir",
  "open", "read", "readFile", "readdir", "readlink", "realpath", "rename", "rmdir", "stat",
  "symlink", "truncate", "unlink", "utimes", "write", "writeFile" ]

dfs = {}
dfs[ m ] = Promise.promisify fs[ m ] for m in methods

module.exports = dfs
