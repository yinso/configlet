argv = require '../src/argv'
{ assert } = require 'chai'
Schema = require 'schemalet'
require 'yamlify'

describe 'argv extraction test', ->

  schema = Schema.makeSchema require '../schema/example'

  it 'can normalize argv', ->
    argvVars = [
      'program'
      '--test.dryRun'
      'true'
      '--database.user'
      'foo'
      '--database.password'
      'pass'
      '--database.host'
      'localhost'
      '--database.port'
      '5432'
      '--port'
      '2001'
      '--sites.0.hostname'
      'foo.com'
      '--sites.1.hostname'
      'bar.com'
    ]

    expected =
      test:
        dryRun: true
      database:
        user: 'foo'
        password: 'pass'
        host: 'localhost'
        port: 5432
      port: 2001

    res = argv.normalize schema, argvVars
    assert.deepEqual res, expected



