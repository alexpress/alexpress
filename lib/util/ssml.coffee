'use strict'
module.exports =
  fromStr : ( str, current_ssml ) ->
    # remove any <speak> tags from the input string, if they exist. There can only be one set of <speak> tags.
    str = str or ''
    str = str.replace( /<speak>/gi, ' ' ).replace( /<\/speak>/gi, ' ' ).trim()
    # and remove them from the concatenated string, if exists
    current_ssml = current_ssml or ''
    current_ssml = current_ssml.replace( /<speak>/gi, ' ' ).replace( /<\/speak>/gi, ' ' ).trim()
    #TODO: Need a library with how to easily construct these statements with appropriate spacing, etc.
    #TODO: make sure all attribute values are surrounded by "..."
    ssml_str = '<speak>' + current_ssml + (if current_ssml == '' then '' else ' ') + str + '</speak>'
    ssml_str.replace RegExp( '  +' ), ' '

  cleanse : ( str ) ->
    # <p> is left in place to support intended HTML output
    str.replace( /<\/?(speak|break|phoneme|audio|say-as|s\b|w\b)[^>]*>/gi, ' ' ).replace( /\s*\n\s*/g, '\n' ).replace( RegExp( '  +', 'g' ), ' ' ).replace( RegExp( ' ([.,!?;:])', 'g' ), '$1' ).trim()
