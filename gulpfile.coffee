gulp = require('gulp')
$ = require('gulp-load-plugins')()
runSequence = require('run-sequence')
del = require('del')
gutil = require('gutil')

paths = 
  dependencies: [ 'bower_components/**/*' ]
  pages:
    src: [ 'src/*.haml' ]
  # scripts:
  # styles:
  #   forElements:
  #     toCompile: [ 'app/elements/*/*.sass' ]
  #     compiled: [ 'dist/elements/*/*.css' ]
  #   forApp:
  #     [ 'app/styles/*.sass' ]
  # resources:
  #   meta: [ 'app/resources/*/*.cson' ]
  #   content: [ 'app/resources/*/*.*', '!app/resources/*/*.cson' ]
  # elements:
  #   toVulcanize: [ 'dist/elements/elements.html' ]
  #   vulcanized: [ 'dist/elements/elements.vulcanized.html' ]
  # othersToCopy: [ 'app/*.*' ]

gulp.task 'clean', (cb) ->
  del [ '.tmp', 'dist/*' ], cb

gulp.task 'copy-dependencies', ->
  # TODO link instead of copy
  gulp
    .src paths.dependencies
    .pipe gulp.dest 'dist/bower_components'

gulp.task 'build-pages', ->
  gulp
    .src paths.pages.src
    .pipe $.rubyHaml().on('error', gutil.log)
    .pipe gulp.dest('dist/')

gulp.task 'build', (cb) ->
  runSequence(
    'clean'
    'copy-dependencies'
    [ 'build-pages' ]
    # ['build-pages', 'build-scripts', 'build-styles']
    cb
  )

gulp.task 'publish', ->
  

gulp.task 'default', [ 'build', 'publish' ]
