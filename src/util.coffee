isValue = (x) ->
  x != undefined and x != null

isFunction = (obj) ->
  (typeof(obj) == 'function') or (obj instanceof Function)

merge = (target, source) ->
  if (target instanceof Array) and (source instanceof Array)
    mergeArray target, source
  else if (target instanceof Array) or (source instanceof Array) # only one of them is array.
    mergeScalar target, source
  else if isFunction(target) or isFunction(source)
    mergeScalar target, source
  else if (target instanceof Object) and (source instanceof Object)
    mergeObject target, source
  else if (target instanceof Object) and (source == undefined)
    mergeObject target, {}
  else if (target instanceof Object) or (source instanceof Object)
    throw new Error("both_must_be_object")
  else
    mergeScalar target, source

mergeScalar = (target, source) ->
  if source == undefined or source == null
    target
  else
    source

mergeObject = (target, source) ->
  res = {}
  for key, val of target
    if target.hasOwnProperty key
      res[key] =
        if source.hasOwnProperty key
          merge val, source[key]
        else
          merge val
  for key, val of source
    if source.hasOwnProperty key
      if not res.hasOwnProperty key
        res[key] = val
  res

mergeArray = (target, source) ->
  map = {}
  res = []
  for item, i in target
    map[ JSON.stringify(item) ] = item
    res.push item
  for item, i in source
    if not map.hasOwnProperty JSON.stringify item
      res.push item
  res

Schema = require 'schemalet'

normalizeKeys = (obj) ->
  if obj instanceof Array
    _array obj
  else if obj instanceof Object
    _object obj
  else
    obj

_array = (obj) ->
  for item in obj
    normalizeKeys item

intSchema = Schema.makeSchema type: 'integer'

_isArrayKeys = (keys) ->
  for key in keys
    try
      intSchema.convert key
    catch e
      return false
  true

_object = (obj) ->
  keys = Object.keys obj
  if _isArrayKeys keys
    res = []
    for key, val of obj
      res[intSchema.convert(key)] = normalizeKeys val
  else
    res = {}
    for key, val of obj
      res[key] = normalizeKeys val
    res

module.exports =
  merge: merge
  isValue: isValue
  isFunction: isFunction
  normalizeKeys: normalizeKeys

### park this here for now

deepEqual = (a, b) ->
  typeA = typeof a
  typeB = typeof b
  if typeA == typeB
    switch typeA
      when 'number', 'string', 'boolean', 'undefined'
        return a == b
      else # object
        if (a instanceof Array) and (b instanceof Array)
          return deepEqualArray a, b
        else
          return deepEqualObject a, b
  else
    false

deepEqualArray = (a, b) ->
  if a.length != b.length
    return false
  for item, i in a
    if not deepEqual item, b[i]
      return false
  true

deepEqualObject = (a, b) ->
  if Object.keys(a).length != Object.keys(b).length
    return false
  for key, val of a
    if a.hasOwnProperty key
      if not b.hasOwnProperty key
        return false
      if not deepEqual val, b[key]
        return false
  true

###

###
class List

  class ListEnd extends List

  @End = new ListEnd()

  @fromArray: (ary) ->
    current = End
    for item in ary
      current = Cons item, current
    current.reverse()

  constructor: (head, tail = End) ->
    if not (@ instanceof List)
      return new List head, tail
    @head = head
    @tail = tail

  isEnd: () ->
    @tail == End

  toArray: () ->
    ary = []
    current = @
    while not current.isEnd()
      ary.push current.head
      current = current.tail
    ary

  reverse: () ->
    res = End
    current = @
    while not current.isEnd()
      res = List current.head, res
      current = current.tail
    res
###

