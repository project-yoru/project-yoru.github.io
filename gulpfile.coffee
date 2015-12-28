gulp = require('gulp')
$ = require('gulp-load-plugins')()
run_sequence = require('run-sequence')
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
  run_sequence(
    'clean'
    [ 'build-pages' ]
    # ['build-pages', 'build-scripts', 'build-styles']
    cb
  )

gulp.task 'publish', ->
  # 0. manually checkout and push at `source` branch
  $.git
    # 1. checkout to master
    .checkout 'master', (err) -> throw err if err
    # 2. fetch dist from `source`
    .exec {args: 'checkout source -- dist'}, (err) -> throw err if err
  # 3. mv files
  gulp
    .src './dist/**/*'
    .pipe gulp.dest './'
  # 4. commit and push
  $.git
    .add {args: '-A'}, (err) -> throw err if err
    .commit 'auto publishing', (err) -> throw err if err
    .push 'origin', 'master', (err) -> throw err if err

gulp.task 'default', ->
  run_sequence(
    'build'
    'publish'
  )
