parseArgv = require 'minimist'
Schema = require 'schemalet'
AppError = require 'errorlet'
util = require './util'

class ArgvVarPath extends Schema.SchemaPath
  constructor: (path, prev = null) ->
    if not (@ instanceof ArgvVarPath)
      return new ArgvVarPath path, prev
    super path, prev

normalize = (schema, argv = process.argv) ->
  normalized = util.normalizeKeys parseArgv argv
  console.log 'Argv.normalize', normalized
  _normalize schema, normalized, new ArgvVarPath()

_normalize = (schema, obj, path) ->
  console.log "<#{schema.type}>", obj, path.toString()
  switch schema.type
    when 'integer', 'number', 'boolean', 'string', 'null'
      _scalar schema, obj, path
    when 'array'
      _array schema, obj, path
    when 'object'
      _object schema, obj, path
    when 'map'
      _map schema, obj, path
    when 'oneOf'
      _oneOf schema, obj, path

_scalar = (schema, x, path) ->
  if util.isValue x
    try
      schema.convert x, path
    catch e
      return undefined

_array = (schema, ary, path) ->
  if ary instanceof Array
    for item, i in ary
      try
        _normalize schema.inner, item, path.push(i)
      catch e
        undefined
  else
    undefined

_tuple = (schema, ary, path) ->
  if ary instanceof Array
    for inner, i in schema.items
      try
        _normalize inner, ary[i], path.push(i)
      catch e
        undefined
  else
    undefined

_object = (schema, obj, path) ->
  if obj instanceof Object
    result = {}
    for [ key, prop ] in schema.properties
      if obj.hasOwnProperty(key) and util.isValue obj[key]
        res = _normalize prop, obj[key], path.push(key)
        if util.isValue res
          result[key] = res
    result
  else
    undefined

_map = (schema, obj, path) ->
  if obj instanceof Object
    result = {}
    for key, val of obj
      if obj.hasOwnproperty(key) and util.isValue obj[key]
        res = _normalize schema.inner, obj[key], path.push(key)
        if util.isValue res
          result[key] = res
    result
  else
    undefined

_oneOf = (schema, obj, path) ->
  for inner, i in schema.items
    try
      return _normalize item, obj, path.push(i)
    catch e
      continue
  undefined

module.exports =
  normalize: normalize

