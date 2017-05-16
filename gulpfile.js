// Constants

const NODEJS_EXCLUDE_PATTERN = ["!build{,/**}", "!node_modules{,/**}"] // ignore folder and all its hierarchy
const CONFIG_FILES = ["pkgmeta.yaml", "debugconfig.yaml"]

// Requiring node packages :

var gulp = require("gulp");
var del = require("del");
var combine = require("stream-combiner");
var yaml = require("js-yaml");
var fs = require("fs");

// Variables :

var config = {};

function loadconfig(){
    config = {}
    CONFIG_FILES.map(function(element){
        var file = yaml.safeLoad(fs.readFileSync(element));
        for(var k in file){
            if(!config[k]){
                config[k] = file[k]
            }
            else if(config[k] instanceof Array){
                config[k] = config[k].concat(file[k])
            }
        }
    }); 
}

//Load config file task
gulp.task('build', ['clean'], function() {
    var paths = ["**"]
    .concat(config.ignore.map(function(element) { return "!" + element}))
    .concat(NODEJS_EXCLUDE_PATTERN);
    return gulp.src(paths, {base: '.'}).pipe(combine(config.debug_deploy_paths.map(function(element) {
        return gulp.dest(element + '/' + config["package-as"]);
    })));
});

gulp.task('clean', function() {
    return del(config.debug_deploy_paths.map(function(element) {
        return element + '/' + config["package-as"] 
    }));
})

gulp.task('watch', function() {
    var watcher = gulp.watch("**", {interval : 1000}, ['build']);
    watcher.on('change', function(event) {
        console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
    });
    return watcher;
});

gulp.task('default', ['build', 'watch']);