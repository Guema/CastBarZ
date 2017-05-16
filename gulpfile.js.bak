// Requiring node packages :
var gulp = require('gulp');
var del = require('del');
var combine = require('stream-combiner');
// Require config file :
var config = require("./gulpconfig.json");

function to_build() {
    return config.to_include
        .concat(config.to_exclude.map(function(element) { return "!" + element}))
        .concat(["!build", "!build/**"]);
}

function to_watch() {
    return config.to_include
        .concat(["!gulpfile.js", "!build/", "!build/**"]);
}

function target() {
    var tar = ["./build/" + config.addon_name];
    if(config.wow_addons_path != null)
    {
        tar.push(config.wow_addons_path + "/" + config.addon_name);
    }
    return tar;
}

function dests() {
    return combine(target().map(function(element) {
        return gulp.dest(element);
    }));
}

gulp.task('default', ['build', 'watch']);

gulp.task('build', ['clean', 'reload'], function() {
    return gulp.src(to_build(), { base: '.' }).pipe(dests());
});

gulp.task('clean', function() {
    return del( target(), {force: true});
});

gulp.task('watch', function() {
    var watcher = gulp.watch(to_watch(), {interval : 1000}, ['clean', 'build']);
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