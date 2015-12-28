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
  # 0. manually checkout and push at `source` branch
  # 1. checkout to master
  $.git.checkout 'master', (err) -> throw err if err
  # 2. fetch dist from `source`
  $.git.checkout 'source', {args: '-- dist'}
  # 3. mv files
  gulp
    .src './dist/**/*'
    .pipe gulp.dest './'
  # 4. commit and push

gulp.task 'default', [ 'build', 'publish' ]
