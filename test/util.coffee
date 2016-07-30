util = require '../src/util'
{ assert } = require 'chai'

describe 'util test', ->

  it 'can merge scalars', ->
    
    assert.equal util.merge(1, 2), 2
    assert.equal util.merge(true, 'hello'), 'hello'
    assert.equal util.merge(1, null), 1
    assert.equal util.merge('test', undefined), 'test'

  it 'can merge objects', ->
    a =
      foo: 1
      bar: 2
      baz: 3
    b =
      abc: 1
      bar: 'hello'
      baw: 5
    assert.deepEqual util.merge(a, b),
      foo: 1
      bar: 'hello'
      baz: 3
      abc: 1
      baw: 5

  it 'can merge nested objects', ->
    a =
      foo:
        a: 'test'
        b: 'hello'
    b =
      bar: 'test'
      foo:
        b: 'test me'
        c: 'test me again'
    expected =
      bar: 'test'
      foo:
        a: 'test'
        b: 'test me'
        c: 'test me again'
    assert.deepEqual util.merge(a, b), expected

  it 'can merge arrays', ->
    a = [1 , 2 , 3 ]
    b = [ 2 , 3 , 4 ]
    expected = [ 1 , 2 , 3 , 4 ]
    assert.deepEqual util.merge(a, b), expected

  it 'can merge arrays of object types', ->
    a = [ { foo: 1 }, { foo : 2 } , 3]
    b = [ { foo: 3 } , { foo : 2 } ]
    expected = [ { foo: 1 }, { foo: 2 } , 3 , { foo: 3 } ]
    assert.deepEqual util.merge(a, b), expected
  
  it 'can merge nested arrays', ->
    a =
      foo: [ { foo: 1 }, { foo : 2 } , 3]
    b =
      foo: [ { foo: 3 } , { foo : 2 } ]
    expected =
      foo: [ { foo: 1 }, { foo: 2 } , 3 , { foo: 3 } ]
    assert.deepEqual util.merge(a, b), expected

  it 'can normalize object keys', ->
    a =
      '0': 1
      '1': 2
      '2': 3
      '3': 4
      '4': 5

    expected = [1, 2, 3, 4, 5]
    assert.deepEqual util.normalizeKeys(a), expected

    b =
      foo: a
    expected2 =
      foo: expected

    assert.deepEqual util.normalizeKeys(b), expected2
    


