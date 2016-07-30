Schema = require 'schemalet'
util = require './util'
rJson = require 'relaxed-json'

class EnvVarPath extends Schema.SchemaPath
  constructor: (path, prev) ->
    if not (@ instanceof EnvVarPath)
      return new EnvVarPath path, prev
    super path, prev
  push: (path) ->
    new EnvVarPath path, @
  getValue: (envVars) ->
    name = @toString()
    #console.log 'EnvVarPath.getValue', name, envVars
    if envVars.hasOwnProperty name
      return envVars[name]
    name = name.toUpperCase()
    if envVars.hasOwnProperty name
      return envVars[name]
    name = name.toLowerCase()
    if envVars.hasOwnProperty name
      return envVars[name]
    undefined
  toString: () ->
    #console.log 'EnvVarPath.toString()'
    res = []
    current = @
    while current
      if current.path != ''
        res.unshift current.path
      current = current.prev
    res.join '_'

normalize = (schema, envVars, path = EnvVarPath(), acc = undefined) ->
  schema =
    if schema instanceof Schema
      schema
    else
      Schema.makeSchema schema
  switch schema.type
    when 'integer', 'boolean', 'string', 'number'
      normalizeScalar schema, envVars, path, acc
    when 'array' # this one is a bit more crazy... need to think about what to do...
      normalizeArray schema, envVars, path, acc
    when 'object'
      normalizeObject schema, envVars, path, acc
    when 'oneOf'
      normalizeOneOf schema, envVars, path, acc
    else
      throw new Error("Unknown schema type: " + schema.type)

normalizeArray = (schema, envVars, path, acc) ->
  #console.log "normalize#{schema.type}", path.toString()
  envVarName = path.toString()
  val = path.getValue envVars
  if util.isValue val
    schema.convert parseArray val
  else
    undefined

normalizeOneOf = (schema, envVars, path, acc) ->
  for inner in schema.items
    try
      return normalize inner, envVars, path, acc
    catch e
      continue
  undefined

normalizeScalar = (schema, envVars, path, acc) ->
  #console.log "normalize#{schema.type}", path.toString()
  #console.log "<#{schema.type}>", path.toString(), acc
  val = path.getValue envVars
  if util.isValue val
    schema.convert val
  else
    undefined

parseArray = (str) ->
  #console.log 'parseArray', str
  prefix =
    if str.match(/^\s*\[/)
      ''
    else
      '['
  postfix =
    if str.match(/\]\s*$/)
      ''
    else
      ']'
  rJson.parse prefix + str + postfix

parseObject = (str) ->
  #console.log 'parseObject', str
  prefix =
    if str.match(/^\s*\{/)
      ''
    else
      '{'
  postfix =
    if str.match(/\}\s*$/)
      ''
    else
      '}'
  rJson.parse prefix + str + postfix

normalizeObject = (schema, envVars, path, acc) ->
  #console.log 'normalizeObject', path.toString()
  val = path.getValue envVars
  if util.isValue val
    #console.log 'normalizeObject', path.toString(), val, envVars
    if typeof val == 'string'
      acc = normalize schema, parseObject(val), path
    else if val instanceof Object
      acc = normalize schema, val, path
  for [ key, prop ] in schema.properties
    inner = normalize prop, envVars, path.push(key) # the question is - how can this be overwritten??? we don't know!
    if util.isValue inner
      if not (acc instanceof Object)
        acc = {}
      acc[key] = inner
  acc

module.exports =
  normalize: normalize
  EnvVarPath: EnvVarPath

