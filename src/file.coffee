
util = require './util'
fs = require 'fs'
path = require 'path'
os = require 'os'
jsYaml = require 'js-yaml'
AppError = require 'errorlet'

defaultOpts =
  rootPath: process.cwd()
  basePath: './config/'
  loadOrder: () ->
    [
      'default'
      (process.env.NODE_ENV || process.env.ENV || 'development')
      os.hostname()
      'local'
    ]
  extMap:
    'json': JSON.parse
    'yml': jsYaml.safeLoad
    'yaml': jsYaml.safeLoad

readFileSync = (filePath, extParserMap) ->
  for extname, parser of extParserMap
    try
      data = fs.readFileSync filePath + '.' + extname, 'utf8'
      return parser data
    catch e
      continue
  {}

loadSync = (options = {}) ->
  # base path =
  innerOptions = util.merge defaultOpts, options
  loadOrderFileNames = innerOptions.loadOrder()
  res = {}
  for fileName in loadOrderFileNames
    res = util.merge res, readFileSync path.join(innerOptions.rootPath, innerOptions.basePath + fileName), innerOptions.extMap
  res

module.exports =
  loadSync: loadSync
  defaultOpts: defaultOpts

