fs            = require 'fs'
wrench        = require 'wrench'
{print}       = require 'util'
which         = require 'which'
{spawn, exec} = require 'child_process'

# ANSI Terminal Colors
bold  = '\x1B[0;1m'
red   = '\x1B[0;31m'
green = '\x1B[0;32m'
reset = '\x1B[0m'

REPORTER = 'dot'
COVERAGE_FILE = 'coverage.html'

pkg = JSON.parse fs.readFileSync('./package.json')
testCmd = pkg.scripts.test
startCmd = pkg.scripts.start


log = (message, color, explanation) ->
  color = color || ""
  console.log color + message + reset + ' ' + (explanation or '')

# Compiles app.coffee and src directory to the .app directory
build = (callback) ->
  options = ['-c','-b', '-o', 'lib', 'src']
  cmd = which.sync 'coffee'
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  coffee.on 'exit', (status) -> callback?() if status is 0

# mocha test
test = (reporter, output, callback) ->

  if typeof reporter is "function"
    callback = reporter
    reporter = REPORTER
    output = null

  if typeof output is "function"
    callback = output
    output = null

  options = [
    '--globals'
    'hasCert,res'
    '--reporter'
    reporter
    '--compilers'
    'coffee:coffee-script'
    '--colors'
    '--require'
    'should'
    '--require'
    'assert',
    'test/**/*.coffee'
  ]
  try
    cmd = './node_modules/.bin/mocha'
    process.env.NODE_ENV = 'test'
    spec = spawn cmd, options
    spec.stdout.pipe output || process.stdout
    spec.stderr.pipe process.stderr
    spec.on 'exit', (status) -> callback?() if status is 0 or status is 2
  catch err
    log err.message, red
    log 'Mocha is not installed - try npm install mocha -g', red

# Coverage
coverage = (callback) ->
  process.env.TEXY_COV = 1
  test "html-cov", (stream = fs.createWriteStream COVERAGE_FILE), ->
    stream.close()
    callback?()

# RM nonempty dir
deleteFolderRecursive = (path) ->
  if fs.existsSync(path)
    fs.readdirSync(path).forEach (file, index) ->
      curPath = path + "/" + file
      if fs.statSync(curPath).isDirectory()
        deleteFolderRecursive curPath
      else
        fs.unlinkSync curPath
    fs.rmdirSync path

clean = (callback) ->
  deleteFolderRecursive 'docs'
  deleteFolderRecursive 'lib-cov'
  fs.unlinkSync COVERAGE_FILE if fs.existsSync COVERAGE_FILE
  callback?()

libCov = (callback) ->
  cmd = which.sync "jscoverage"
  spec = spawn cmd, ["lib", "lib-cov"]
  spec.stdout.pipe process.stdout
  spec.stderr.pipe process.stderr
  spec.on 'exit', (status) -> callback?() if status is 0

#
# Tasks
#
task 'cov', "Generates coverega code", ->
  clean -> build -> libCov -> coverage -> log ":)", green

task 'build', ->
  clean -> build -> log ":)", green

task 'spec', 'Run Mocha tests', ->
  invoke 'test'

task 'test', 'Run Mocha tests', ->
  clean -> build -> test ->log ":)", green

task 'docs', 'Generate annotated source code with Docco', ->
  files = wrench.readdirSyncRecursive("src")
  files = ("src/#{file}" for file in files when /\.coffee$/.test file)
  log files
  try
    cmd ='./node_modules/.bin/docco-husky'
    docco = spawn cmd, files
    docco.stdout.pipe process.stdout
    docco.stderr.pipe process.stderr
    docco.on 'exit', (status) -> callback?() if status is 0
  catch err
    log err.message, red
    log 'Docco is not installed - try npm install docco -g', red

task 'dev', 'start dev env', ->
  # watch_coffee
  options = ['-c', '-b', '-w', '-o', '.app', 'src']
  cmd = which.sync 'coffee'
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  log 'Watching coffee files', green
  # watch_js
  supervisor = spawn 'node', [
    './node_modules/supervisor/lib/cli-wrapper.js',
    '-w',
    '.app,views',
    '-e',
    'js|jade',
    'dev-server'
  ]
  supervisor.stdout.pipe process.stdout
  supervisor.stderr.pipe process.stderr
  log 'Watching js files and running server', green

task 'debug', 'start debug env', ->
  # watch_coffee
  options = ['-c', '-b', '-w', '-o', '.app', 'src']
  cmd = which.sync 'coffee'
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  log 'Watching coffee files', green
  # run debug mode
  app = spawn 'node', [
    '--debug',
    'server'
  ]
  app.stdout.pipe process.stdout
  app.stderr.pipe process.stderr
  # run node-inspector
  inspector = spawn 'node-inspector'
  inspector.stdout.pipe process.stdout
  inspector.stderr.pipe process.stderr
  # run google chrome
  chrome = spawn 'google-chrome', ['http://0.0.0.0:8080/debug?port=5858']
  chrome.stdout.pipe process.stdout
  chrome.stderr.pipe process.stderr
  log 'Debugging server', green

task 'clean', 'removes files', ->
  clean -> log ':)', green

#option '-n', '--name [NAME]', 'name of model to `scaffold`'
#task 'scaffold', 'scaffold model/controller/test', (options) ->
#  if not options.name?
#    log "Please specify model name", red
#    process.exit(1)
#  log "Scaffolding `#{options.name}`", green
#  scaffold = require './scaffold'
#  scaffold options.name



