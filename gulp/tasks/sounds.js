var changed    = require('gulp-changed');
var gulp       = require('gulp');
var config     = require('../config').sounds;

gulp.task('sounds', function() {
  return gulp.src(config.src)
    .pipe(changed(config.dest)) // Ignore unchanged files
    .pipe(gulp.dest(config.dest));
});
