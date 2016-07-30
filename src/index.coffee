Schema = require 'schemalet'
argvParser = require 'minimist'
rJson = require 'relaxed-json'
util = require './util'
env = require './env'
argv = require './argv'
file = require './file'

parseSync = (schemaSpec, options = {}) -> # the option
  options =
    argv:
      if options.hasOwnProperty 'argv'
        options.argv
      else
        process.argv.slice(2)
    env:
      if options.hasOwnProperty 'env'
        options.env
      else
        process.env
    rootPath: util.merge file.defaultOpts.rootPath, options.rootPath
    basePath: util.merge file.defaultOpts.basePath, options.basePath
    loadOrder: util.merge file.defaultOpts.loadOrder, options.loadOrder
    extMap: util.merge file.defaultOpts.extMap, options.extMap

  schema = Schema.makeSchema schemaSpec
  configVal = file.loadSync options # we can pass in options here.
  envVal = env.normalize schema, options.env
  argvVal = argv.normalize schema, options.argv
  console.log 'configVal', configVal
  console.log 'envVal', envVal
  console.log 'argvVal', argvVal
  merge1 = util.merge configVal, envVal
  merge2 = util.merge merge1, argvVal
  console.log 'merged', merge2
  schema.convert merge2

module.exports =
  parseSync: parseSync


