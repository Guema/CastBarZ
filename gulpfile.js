// Requiring node packages :
var gulp = require('gulp');
var del = require('del');
var config = require("./gulpconfig.json");

gulp.task('default', ['build', 'watch']);

gulp.task('build', ['clean', 'reload'], function() {
   var paths = config.to_include.slice();
   config.to_exclude.forEach(function(element) {
      paths.push('!' + element);
   }, this);
   return gulp.src(paths, { base: '.' }).pipe(gulp.dest(config.wow_path + '/Interface/Addons/' + config.addon_name));
});

gulp.task('clean', function() {
   return del(config.wow_path + '/Interface/Addons/' + config.addon_name + "/*", {force: true});
});

gulp.task('watch', function() {
   var paths = config.to_include.concat("./gulpconfig.json");
   var watcher = gulp.watch(paths, ['clean', 'build']);
   watcher.on('change', function(event) {
      console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
   });  
   return watcher;
});

gulp.task('reload', function() {
    delete require.cache[require.resolve("./gulpconfig.json")];
    config = require("./gulpconfig.json");
    return;
});