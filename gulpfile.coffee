# TODO concat
# TODO watch and browser sync

gulp = require('gulp')
$ = require('gulp-load-plugins')()
run_sequence = require('run-sequence')
del = require('del')
gutil = require('gutil')

paths = 
  pages:
    src: [ 'src/*.haml' ]
    tmp_dist: 'tmp_dist/'
  images:
    src: [ 'src/images/**' ]
    tmp_dist: 'tmp_dist/images'
  scripts:
    src: [ 'src/scripts/**/*.coffee' ]
    tmp_dist: 'tmp_dist/scripts'
  styles:
    src: [ 'src/styles/**/*.{sass,scss}' ]
    tmp_dist: 'tmp_dist/styles'
  fonts:
    src: [ 'src/fonts/**' ]
    tmp_dist: 'tmp_dist/fonts'
  vendor:
    src: [ 'src/vendor/**/*' ]
    tmp_dist: 'tmp_dist/vendor'

gulp.task 'clean', (cb) ->
  del [ 'dist', 'tmp_dist' ], cb

gulp.task 'copy-vendor', ->
  gulp
    .src paths.vendor.src
    .pipe gulp.dest paths.vendor.tmp_dist

gulp.task 'build-pages', ->
  # TODO vulcanize
  gulp
    .src paths.pages.src
    .pipe $.rubyHaml().on('error', gutil.log)
    .pipe gulp.dest paths.pages.tmp_dist

gulp.task 'build-images', ->
  gulp
    .src paths.images.src
    .pipe $.imagemin
      progressive: true
    .pipe gulp.dest paths.images.tmp_dist

gulp.task 'build-scripts', ->
  # TODO compress
  gulp
    .src paths.scripts.src
    .pipe $.coffee().on('error', gutil.log)
    .pipe gulp.dest paths.scripts.tmp_dist

gulp.task 'build-styles', ->
  # TODO compress
  $.rubySass paths.styles.src
    .on 'error', gutil.log
    .pipe gulp.dest paths.styles.tmp_dist

gulp.task 'build-fonts', ->
  gulp
    .src paths.fonts.src
    .pipe gulp.dest paths.fonts.tmp_dist

gulp.task 'build-to-tmp', (cb) ->
  run_sequence(
    'clean'
    'copy-vendor'
    [ 'build-pages', 'build-images', 'build-scripts', 'build-styles', 'build-fonts' ]
    cb
  )

gulp.task 'clean-up', (cb) ->
  del [ '.sass-cache', 'tmp_dist' ], cb

gulp.task 'revision-and-rename-assets', ->
  cdn_prefix = 'http://7xpm8d.com2.z0.glb.qiniucdn.com/'
  rev_all = new ($.revAll)
    hashLength: 16
    dontRenameFile: [ '/index.html' ]
    transformPath: (rev, source, path) ->
      cdn_prefix + rev

  gulp.src('tmp_dist/**')
    .pipe(rev_all.revision())
    .pipe(gulp.dest('dist'))

gulp.task 'publish-github', ->
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

gulp.task 'default', [ 'build-to-tmp' ]
gulp.task 'deploy', ->
  run_sequence(
    'build-to-tmp'
    'revision-and-rename-assets'
    'clean-up'
    'publish-github'
  )
