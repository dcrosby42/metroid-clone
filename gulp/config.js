var dest = "./build";
var src = './src';
var test = './test';

specSrc = "./spec/**/*_{spec,test}.coffee";
if ((spec = process.env['SPEC']) != undefined) {
  specSrc = spec;
}


module.exports = {
  spec: {
    src: specSrc
  },
  browserSync: {
    server: {
      // We're serving the src folder as well
      // for sass sourcemap linking
      baseDir: [dest, src]
    },
    files: [
      dest + "/**",
      // Exclude Map files
      "!" + dest + "/**.map"
    ]
  },
  sass: {
    src: src + "/sass/*.{sass,scss}",
    dest: dest,
    settings: {
      // Required if you want to use SASS syntax
      // See https://github.com/dlmanning/gulp-sass/issues/81
      sourceComments: 'map',
      imagePath: '/images' // Used by the image-url helper
    }
  },
  images: {
    src: src + "/images/**",
    dest: dest + "/images"
  },
  sounds: {
    src: src + "/sounds/**",
    dest: dest + "/sounds"
  },
  markup: {
    src: src + "/htdocs/**",
    dest: dest
  },
  browserify: {
    // Enable source maps
    debug: true,
    // Additional file extentions to make optional
    extensions: ['.coffee', '.hbs'],
    // A separate bundle will be generated for each
    // bundle config in the list below
    bundleConfigs: [{
      entries: src + '/javascript/app.coffee',
      dest: dest,
      outputName: 'app.js'
    }, {
      entries: src + '/javascript/head.coffee',
      dest: dest,
      outputName: 'head.js'
    }]
  }
};
