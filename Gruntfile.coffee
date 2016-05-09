PACKAGES = [
  'grunt-contrib-watch'
  'grunt-contrib-coffee'
  'grunt-contrib-clean'
  'grunt-coffeelint'
  'grunt-coveralls'
]

module.exports = ( grunt ) ->

  grunt.initConfig
    pkg : grunt.file.readJSON "package.json"

    clean :
      dist : [ "dist", "*.{js,map}", "lib/**/*.{map,js}" ]

    coffeelint :
      app : [ 'lib/**/*.coffee', "*.coffee" ]
      
    coveralls:
      app:
        src: 'coverage/lcov.info'

    coffee :
      options :
        sourceMap : false
        bare : true
        force : true

      dist :
        expand : true
        src : [ "lib/**/*.coffee", "*.coffee", "!Gruntfile.coffee" ]
        dest : "dist"
        ext : '.js'

    watch :
      dist :
        tasks : [ "coffee:dist" ]
        files : [ "lib/**/*coffee", "*.coffee" ]

  grunt.loadNpmTasks pkg for pkg in PACKAGES

  grunt.registerTask "default", [ "coffeelint", "clean:dist", "coffee:dist" ]

