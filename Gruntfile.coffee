module.exports = (grunt) ->
  
  #different builds:
  # browser
  # -->standalone (index.html)
  # -->integration (custom element + deps only)
  # desktop
  # -->linux
  # -->win
  # -->mac

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    currentBuild: null
    appname:null
    uglify:
      main:
        options:
          banner: "/*! <%= pkg.name %> <%= grunt.template.today(\"yyyy-mm-dd\") %> */\n"
        dist:
          files:
            "public/<%= pkg.name %>.min.js": ["public/main.js"]

      integration:
        options: {}
        files:
          "build/<%= currentBuild %>/polymer-nw-example.min.js": ["build/<%= currentBuild %>/polymer-nw-example.js"]
          "build/<%= currentBuild %>/platform.min.js": ["build/<%= currentBuild %>/platform.js"]

      standalone:
        files:
          "build/<%= currentBuild %>/index.min.js": ["build/<%= currentBuild %>/index.js"]
          "build/<%= currentBuild %>/platform.min.js": ["build/<%= currentBuild %>/platform.js"]

    exec:
      standalone:
        command: "vulcanize index.html -o build/<%= currentBuild %>/index.html"
        stdout: true
        stderr: true

      integration:
        command: "vulcanize --csp -i smoke.html -o build/<%= currentBuild %>/polymer-nw-example.html"
        stdout: true
        stderr: true


    replace:
      integration:
        src: ["build/<%= currentBuild %>/polymer-nw-example.html"]
        dest: "build/<%= currentBuild %>/polymer-nw-example.html"
        replacements: [
          from: "../components/platform"
          to: ""
        ,
          from: "../components/"
          to: ""
        ,
          from: "polymer-nw-example.js"
          to: "polymer-nw-example.min.js"
        ]

      desktopPost:
        src: ["build/<%= currentBuild %>/index.html"]
        overwrite:true
        replacements: [
          from: "../../components/"
          to: ""
        ,
          from: "../components/"
          to: ""
        ,
          from: '<script src="polymer/polymer.js"></script>'
          to: '<script src="polymer.js"></script>'
        ,
          from: '<script src="platform/platform.js"></script>'
          to: '<script src="platform.js"></script>'
        ]
      standalone:
        src: ["build/<%= currentBuild %>/platform.js"]
        dest: "build/<%= currentBuild %>/platform.js"
        replacements: [
          from: "global" # string replacement
          to: "fakeGlobal"
        ]

    copy:
      integration:
        files: [
          #{src: 'components/platform/platform.js.map',dest: 'build/<%= currentBuild %>/platform.js.map'} ,
          src: "components/platform/platform.js"
          dest: "build/<%= currentBuild %>/platform.js"
        ]
      standalone:
        files: [
          {src: 'components/platform/platform.js.map',dest: 'build/<%= currentBuild %>/platform.js.map'},{src: 'components/platform/platform.js', dest: 'build/<%= currentBuild %>/platform.js'},{src: "components/polymer/polymer.js", dest: "build/<%= currentBuild %>/polymer.js"}
        ]
      desktop:
        files: [
          src: "package.json"
          dest: "build/<%= currentBuild %>/package.json"
          {src: ['demo-data/**'], dest: 'build/<%= currentBuild %>/'}
          {src: ['main.js'], dest: 'build/<%= currentBuild %>/main.js'}
          #{expand: true, src: ['components/**'], dest: 'build/<%= currentBuild %>'}
        ]
      desktopFinal:
        files: [
          {expand: true, src: ['_tmp/desktop/**'], dest: 'build/<%= currentBuild %>'},
        ]
      desktopFoo:
        files: [
          #{expand: true, cwd:'build/<%= currentBuild %>/', src: ['**'], dest: '_tmp/back'},
          #{expand: true, cwd:'build/<%= currentBuild %>/', src: ['**'], dest: 'build/<%= currentBuild %>/resources/app'},
          #{expand: true, cwd:'_tmp/desktop/', src: ['**'], dest: 'build/<%= currentBuild %>/',mode:true},
        ]
        #{expand: true,src:"build/<%= currentBuild %>/**",dest:"build/<%= currentBuild %>/resources/app/"}

    rename:
      desktopFinal:
        src: 'build/<%= currentBuild %>' 
        dest: '_tmp/app'
      
      desktopFinalTOO:
        dest: 'build/<%= currentBuild %>/resources/app' 
        src: '_tmp/app'
      
      appname:
        src: 'build/<%= currentBuild %>/atom'
        dest: 'build/<%= currentBuild %>/<%= appname %>'  
      

    htmlmin:
      integration:
        options: {}
        files: # Dictionary of files
          "build/integration/polymer-nw-example.html": "build/integration/polymer-nw-example.html"

    clean:
      integration: ["build/<%= currentBuild %>"]
      postIntegration: ["build/<%= currentBuild %>/platform.js", "build/<%= currentBuild %>/polymer-nw-example.js"]
      standalone: ["build/<%= currentBuild %>"]
      postStandalone: ["build/<%= currentBuild %>/platform.js", "build/<%= currentBuild %>/index.js"]

      desktop:["build/<%= currentBuild %>"]
      postDesktop:["build/<%= currentBuild %>/resources/default_app/"]
    
    "download-atom-shell":
      version: '0.15.5'
      outputDir: "build/<%= currentBuild %>"
      downloadDir:'_tmp/cache'
      rebuild:false
      
    compress:
      desktop:
        options: 
          archive: "build/<%= currentBuild %>/<%= appname %>.zip"
        expand: true
        cwd: 'build/<%= currentBuild %>/'
        src: ['**']
        dest: ''
          
  
  #generic
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-rename"
  grunt.loadNpmTasks "grunt-exec"
  grunt.loadNpmTasks "grunt-text-replace"
  grunt.loadNpmTasks "grunt-contrib-clean"
  
  #builds generation
  grunt.loadNpmTasks "grunt-browserify"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-htmlmin"
  grunt.loadNpmTasks "grunt-download-atom-shell"
  grunt.loadNpmTasks "grunt-contrib-compress"
  
  #release cycle

  # Task(s).
  grunt.registerTask "core", ["browserify", "uglify:main"]
  
  #Builds
  @registerTask 'build', 'Build polymer-nw-example for the chosen target/platform etc', (target = 'browser', subTarget='standalone') =>
    minify = grunt.option('minify');
    platform = grunt.option('platform');
    appname = grunt.option('appname');
    compress = grunt.option('compress');
    console.log("target", target, "sub", subTarget,"minify",minify,"platform",platform,"appname", appname)
    
    grunt.config.set("currentBuild", "#{target}-#{subTarget}")
    grunt.config.set("appname", appname);
    
    @task.run "clean:#{subTarget}"
    @task.run "copy:#{subTarget}"
    @task.run "exec:#{subTarget}"
    @task.run "replace:#{subTarget}"

    if minify
      @task.run "uglify:#{subTarget}"
      #issues with ,'htmlmin:integration'
      postClean = subTarget[0].toUpperCase() + subTarget[1..-1].toLowerCase()
      @task.run "clean:post#{postClean}"

    if target is 'desktop'
      @task.run "replace:desktopPost"
      @task.run "copy:desktop"
      
      @task.run "rename:desktopFinal"
      @task.run "download-atom-shell"
      @task.run "rename:desktopFinalTOO" #copy things back
      @task.run "clean:postDesktop"#remove the default_app folder
    
      if appname
        @task.run "rename:appname"
      
      if compress
        @task.run "compress:desktop"#currently losing correct flags for executables, see https://github.com/gruntjs/grunt-contrib-compress/pull/110

