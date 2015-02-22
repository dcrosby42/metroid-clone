var gulp = require('gulp');
var config = require('../config')['spec'];

// IMPORTANT: CoffeeScript needs to be reigstered BEFORE Mocha, 
// in order to support writing specs in CoffeeScript
require('coffee-script/register') 
var mocha = require('gulp-mocha');

gulp.task('spec', function () {
  return gulp
    .src(config.src, {read: false})
    .pipe(mocha({
      //reporter: 'nyan',
    }));
});
