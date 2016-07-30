env = require '../src/env'
{ assert } = require 'chai'
Schema = require 'schemalet'
require 'yamlify'

describe 'env extraction test', ->

  schema = Schema.makeSchema require '../schema/example'

  it 'can normalize env', ->
    envVars =
      TEST_DRYRUN: true
      DATABASE_USER: 'foo'
      DATABASE_PASSWORD: 'pass'
      DATABASE_HOST: 'localhost'
      DATABASE_PORT: '5432'
      PORT: '2001'

    expected =
      test:
        dryRun: true
      database:
        user: 'foo'
        password: 'pass'
        host: 'localhost'
        port: 5432
      port: 2001

    res = env.normalize schema, envVars
    assert.deepEqual res, expected


