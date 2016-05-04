module.exports = ( arr, fn, test ) ->
  idx = 0
  p = fn arr[ idx++ ]
  p = p
  .then ( val ) ->
    return val if test val
    return if idx >= arr.length
    fn arr[ idx++ ]
