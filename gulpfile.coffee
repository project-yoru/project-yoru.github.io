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
  # 1. checkout to master
  $.git.checkout 'master', (err) -> throw err if err
  # 2. fetch dist from `source`
  $.git.exec {args: 'checkout source -- dist'}, (err) -> throw err if err
  # 3. mv files
  gulp
    .src './dist/**/*'
    .pipe gulp.dest './'
  # 4. commit and push
  $.git.exec {args: 'add -A'}, (err) -> throw err if err
  $.git.exec {args: 'commit -m "auto publishing"', (err) -> throw err if err
  $.git.push 'origin', 'master', (err) -> throw err if err

gulp.task 'default', ->
  run_sequence(
    'build'
    'publish'
  )
