// Constants

const NODEJS_EXCLUDE_PATTERN = ["!build{,/**}", "!node_modules{,/**}", "!pkgmeta.yaml"] // ignore folder and all its hierarchy
const CONFIG_FILE = "pkgmeta.yaml"

// Requiring node packages :

var gulp = require("gulp");
var del = require("del");
var combine = require("stream-combiner");
var yaml = require("js-yaml");
var fs = require("fs");

// Variables :

var config;
function reload()
{
    config = yaml.safeLoad(fs.readFileSync(CONFIG_FILE));
}
reload();

//Load config file task
gulp.task('build', function() {
    var paths = ["**"].concat((config.ignore.concat(config.test_build.ignore)).map(function(element) { return "!" + element}))
    .concat(NODEJS_EXCLUDE_PATTERN);
    return gulp.src(paths, {base: '.'}).pipe(combine(config.test_build.paths.map(function(element) {
        return gulp.dest(element + '/' + config["package-as"]);
    })));
});

gulp.task('clean', function() {
    return del(config.test_build.paths.map(function(element) {
        return element + '/' + config["package-as"] + '/*';
    }), {force: true});
});

gulp.task('watch', function() {
    var w1 = gulp.watch("pkgmeta.yaml", { base: ".", interval : 200 }, function(){ gulp.start("clean"); reload(); gulp.start("build"); });
    var w2 = gulp.watch(["**"].concat(NODEJS_EXCLUDE_PATTERN).concat("!pkgmeta.yaml") , { base: ".", interval : 200 }, ["clean", "build"]);
    w1.on('change', function(event) {
        console.log('Config File ' + event.path + 'was ' + event.type + ', reloading config...' );
    });
    w2.on('change', function(event) {
        console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
    });
});

gulp.task('default', ['watch']);