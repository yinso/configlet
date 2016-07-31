Loader = require '../src/index'
require 'yamlify'
spec = require '../schema/example'
{ assert } = require 'chai'

describe 'Loader test', ->
  
  it 'can load config', ->
    result = Loader.parseSync spec
    expected =
      database:
        database: 'test'
        user: 'test'
        password: 'test'
        host: 'localhost'
        port: 5432
        pool:
          min: 0
          max: 25
      test:
        dryRun: false
      files: [
        'foo.html'
        'bar.html'
        'x.js'
      ]
      port: 8080
    assert.deepEqual expected, result

