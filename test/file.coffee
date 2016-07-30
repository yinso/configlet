file = require '../src/file'
{ assert } = require 'chai'

describe 'file loader test', ->

  it 'can load config', ->

    res = file.loadSync()

