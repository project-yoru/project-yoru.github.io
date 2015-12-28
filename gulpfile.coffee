gulp = require('gulp')
$ = require('gulp-load-plugins')()
runSequence = require('run-sequence')
del = require('del')
gutil = require('gutil')

paths = 
  pages:
    src: [ 'src/*.haml' ]
  # scripts:
  # styles:

gulp.task 'clean', (cb) ->
  del [ '.tmp', 'dist/*' ], cb

gulp.task 'build-pages', ->
  gulp
    .src paths.pages.src
    .pipe $.rubyHaml().on('error', gutil.log)
    .pipe gulp.dest('dist/')

gulp.task 'build', (cb) ->
  runSequence(
    'clean'
    [ 'build-pages' ]
    # ['build-pages', 'build-scripts', 'build-styles']
    cb
  )

gulp.task 'publish', ->
  

gulp.task 'default', [ 'build', 'publish' ]
