assert = require 'assert'
_texy = require('../')

describe "Texy", ->
  describe "Library require", ->
    it 'should be function after require', ->
      assert.equal typeof _texy, 'function'
    it 'should be object after require evoke', ->
      texy = _texy()
      assert.equal typeof texy, 'object'
  describe "Object", ->
    texy = _texy()
    it "#test() should return true", ->
      assert texy.test() is true
      assert texy.test() is true


