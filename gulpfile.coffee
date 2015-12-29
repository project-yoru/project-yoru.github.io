# TODO compress, gzip maybe?
# TODO watch and browser sync

gulp = require('gulp')
$ = require('gulp-load-plugins')()
run_sequence = require('run-sequence')
del = require('del')
gutil = require('gutil')

paths = 
  pages:
    src: [ 'src/*.haml' ]
    dist: 'dist/'
  images:
    src: [ 'src/images/**' ]
    dist: 'dist/images'
  scripts:
    src: [ 'src/scripts/**/*.coffee' ]
    dist: 'dist/scripts'
  styles:
    src: [ 'src/styles/**/*.{sass,scss}' ]
    dist: 'dist/styles'
  fonts:
    src: [ 'src/fonts/**' ]
    dist: 'dist/fonts'

gulp.task 'clean', (cb) ->
  del [ 'dist/*' ], cb

gulp.task 'build-pages', ->
  # TODO vulcanize
  gulp
    .src paths.pages.src
    .pipe $.rubyHaml().on('error', gutil.log)
    .pipe gulp.dest paths.pages.dist

gulp.task 'build-images', ->
  gulp
    .src paths.images.src
    .pipe $.imagemin
      progressive: true
    .pipe gulp.dest paths.images.dist

gulp.task 'build-scripts', ->
  # TODO compress
  gulp
    .src paths.scripts.src
    .pipe $.coffee().on('error', gutil.log)
    .pipe gulp.dest paths.scripts.dist

gulp.task 'build-styles', ->
  # TODO compress
  $.rubySass paths.styles.src
    .on 'error', gutil.log
    .pipe gulp.dest paths.styles.dist

gulp.task 'build-fonts', ->
  gulp
    .src paths.fonts.src
    .pipe gulp.dest paths.fonts.dist

gulp.task 'build', (cb) ->
  run_sequence(
    'clean'
    [ 'build-pages', 'build-images', 'build-scripts', 'build-styles', 'build-fonts' ]
    cb
  )

gulp.task 'clean-up', (cb) ->
  del [ '.sass-cache' ], cb

gulp.task 'publish', ->
  # 0. manually checkout and push at `source` branch
  # 1. checkout to master
  # 2. fetch dist from `source`
  # 3. mv files
  # 4. commit and push
  # TODO sometimes wont update file
  commands =
    """
      git checkout master &&
      git checkout source -- dist &&
      rsync -a -v dist/ ./ &&
      rm -rf dist &&
      git add -A &&
      git commit -m 'auto publishing' &&
      git push origin master &&
      git checkout source
    """
  $.run(commands)
    .exec().on 'error', gutil.log

gulp.task 'default', [ 'build' ]
gulp.task 'deploy', ->
  run_sequence(
    'build'
    'clean-up'
    'publish'
  )
