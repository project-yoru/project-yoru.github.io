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
  # 2. fetch dist from `source`
  # 3. mv files
  # 4. commit and push
  commands =
    """
      git checkout master &&
      git checkout source -- dist &&
      mv dist/.[!.]* . &&
      rm -rf dist &&
      git add -A &&
      git commit -m 'auto publishing' &&
      git push origin master
    """
  $.run(commands)
    .exec()
    .pipe gulp.dest 'output'

gulp.task 'default', ->
  run_sequence(
    'build'
    'publish'
  )
