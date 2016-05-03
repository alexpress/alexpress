capitalize = ( str ) ->
  str[ 0 ].toUpperCase() + str[ 1.. ]

endsWith = ( str, pattern ) ->
  str.indexOf( pattern ) is str.length - pattern.length

trimEnd = ( str, pattern ) ->
  if endsWith str, pattern then str[ ..-pattern.length - 1 ] else str

module.exports =
  capitalize : capitalize
  endsWith : endsWith
  trimEnd : trimEnd
