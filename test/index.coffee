Loader = require '../src/index'
require 'yamlify'
spec = require '../schema/example'

describe 'Loader test', ->
  
  it 'can load config', ->
    result = Loader.parseSync spec,
      env:
        TEST_DRYRUN: false
    console.log result

