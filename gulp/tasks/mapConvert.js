var gulp       = require('gulp');
var config     = require('../config').mapConvert;
var changed    = require('gulp-changed');
var through    = require('through2');

//
// mapConvert gulp task
// 
gulp.task('mapConvert', function() {
  return gulp.src(config.src)
    .pipe(changed(config.dest))
    .pipe(mkJsonToCsvConverter())
    .pipe(gulp.dest(config.dest));
});


//
// Create a gulp pipeline step for converting our map csv format into a json file in the build dir.
//
function mkJsonToCsvConverter() {
    return through.obj(function(file, enc, callback){
        if (file.isNull() || file.isDirectory()) {
            this.push(file);
            return callback();
        }

        if (file.isStream()) {
            this.emit('error', new PluginError({
                plugin: 'MapConvert',
                message: 'Streams are not supported.'
            }));
            return callback();
        }

        if (file.isBuffer()) {
            // Convert the CSV string into a JSON string:
            var csvString = file.contents.toString();
            jsonString = csvStringToJsonGridString(csvString);
            file.contents = Buffer.from(jsonString);

            // Change file suffix to .json
            file.path = file.path.replace(/.csv$/, ".json")
            console.log("MapConvert: creating " + file.path);

            this.push(file);
            return callback();
        }
    });
}

//
// CONVERTER CODE:
//

var CSV, blanksToNulls, csvToJsonGrid, csvDataToJsonGrid, csvStringToJsonGrid, csvStringToJsonGridString;
CSV = require('csv-string');

csvToJsonGrid = function(data) {
  return {
    data: data,
    rows: data.length,
    cols: data[0].length
  };
};

blanksToNulls = function(data) {
  var c, cell, i, len, r, results, row;
  results = [];
  for (r = i = 0, len = data.length; i < len; r = ++i) {
    row = data[r];
    results.push((function() {
      var j, len1, results1;
      results1 = [];
      for (c = j = 0, len1 = row.length; j < len1; c = ++j) {
        cell = row[c];
        if (cell === '') {
          results1.push(row[c] = null);
        } else {
          results1.push(void 0);
        }
      }
      return results1;
    })());
  }
  return data;
};

var csvDataToJsonGrid = function(csvData) {
  return csvToJsonGrid(blanksToNulls(csvData));
};

var csvStringToJsonGrid = function(csvString) {
  return csvToJsonGrid(blanksToNulls(CSV.parse(csvString)));
};

var csvStringToJsonGridString = function(csvString) {
  return JSON.stringify(csvToJsonGrid(blanksToNulls(CSV.parse(csvString))));
};
