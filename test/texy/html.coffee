require '../init' # need to be loaded in every test

assert    = require 'assert'
_         = require 'underscore'
Texy_Html = _require 'texy/html'
Texy      = _require 'texy'

ce = (name, attrs = {}) -> Texy_Html.el name, attrs

describe "Texy_Html", ->
  describe "@el", ->
    it "should return object of self", ->
      el = Texy_Html.el('a')
      assert.equal typeof el, "object"
      assert el instanceof Texy_Html

    it "should assign a name and attrs", ->
      attrs =
        class: 'testClass'
        id: "testId"
      el = Texy_Html.el 'a', attrs
      assert.equal el.attrs, attrs
      assert.equal el.name, 'a'

    it "should set text as second parameter", ->
      el = Texy_Html.el 'a', 'Content'
      assert.equal el.getText(), 'Content'

  describe '::getText', ->
    el = Texy_Html.el 'a'

    it 'should return same string as setted', ->
      el.setText('Test')
      assert.equal el.getText(), 'Test'

    it 'should return joined children string', ->
      el._children = ["Hello ", "World"]
      assert.equal el.getText(), 'Hello World'

    it 'should return false if there are objects in children', ->
      el._children = [{}, "Hello"]
      assert.equal el.getText(), false

  describe "::setName", ->
    el = Texy_Html.el('a')
    it "should set name", ->
      assert el.name is 'a'
      el.setName('strong')
      assert el.name is 'strong'

    it 'should know if the element is empty', ->
      el.setName 'hr'
      assert el._isEmpty is true
      el.setName 'p'
      assert el._isEmpty is false
      el.setName 'p', true
      assert el._isEmpty is true

    it 'should throw exception on not null and not string name', ->
      assert.throws ->
        el.setName({})
      , Error

  describe '::setText', ->
    el = Texy_Html.el('a')
    it 'should throw exception on nonscalar argument', ->
      assert.throws ->
        el.setText {}
      , Error

    it 'should let me set boolean, string or number', ->
      assert.doesNotThrow ->
        el.setText true
        el.setText 12
        el.setText 12.2
        el.setText 'a'

  describe '::setHref', ->
    el = Texy_Html.el('a')
    it 'should set the href attrib', ->
      el.setHref 'http://google.com'
      assert el.attrs.href is 'http://google.com'

    it 'sholud proccess query', ->
      el.setHref '/some/path',
        q: 'query'
        page: 1

      assert el.attrs.href is "/some/path?q=query&page=1"

  describe "::add", ->
    el = Texy_Html.el('div')
    child = Texy_Html.el 'a'
    it 'should add new child', ->
      el.add child
      assert el._children[0] is child

  describe "::create", ->
    el = Texy_Html.el('div')
    it 'should create new child and return it', ->
      child = el.create 'b'
      assert el._children[0] is child

  describe "::removeChildren", ->
    it "should remove all children", ->
      el = Texy_Html.el 'divooo'
      el.create 'a'
      assert.equal el._children.length, 1
      el.removeChildren()
      assert.equal el._children.length, 0

  describe "::insert", ->
    el = Texy_Html.el('div')
    childFirst = Texy_Html.el 'c'
    childSecond = Texy_Html.el 'd'
    it "should insert child to given index", ->
      el.removeChildren()
      el.add childFirst
      el.insert 0, childSecond
      assert el._children[0] is childSecond
      assert el._children[1] is childFirst

    it "should append child", ->
      el.removeChildren()
      el.add childFirst
      el.insert null, childSecond
      assert el._children[1] is childSecond
      assert el._children[0] is childFirst

    it "should replace child on given index", ->
      el.removeChildren()
      el.add childFirst
      el.insert 0, childSecond, true
      assert el._children[0] is childSecond
      assert el._children.length is 1

  describe '::endTag', ->
    it 'should return end tag', ->
      el = Texy_Html.el('div')
      assert el.endTag() is '</div>'
    it 'should return empty end tag', ->
      el = Texy_Html.el('hr')
      assert el.endTag() is ''
      el = Texy_Html.el(null)
      assert el.endTag() is ''

  describe '::startTag', ->
    it 'should return simple start tag', ->
      el = Texy_Html.el 'div'
      assert el.startTag() is '<div>'

    it 'should return XHTML valid start tag when it is empty tag', ->
      el = Texy_Html.el 'hr'
      Texy_Html.xhtml = true
      assert el.startTag() is '<hr />'

    it 'should return start tag when it is empty tag and xhtml is false', ->
      el = Texy_Html.el 'hr'
      Texy_Html.xhtml = false
      assert el.startTag() is '<hr>'

    it 'should not have attributes when they are null or false', ->
      el = Texy_Html.el 'div'
      el.setAttrs
        one: false
        two: null
      assert el.startTag() is '<div>'

    it 'should have long attributes when xhtml is true', ->
      el = Texy_Html.el 'div'
      Texy_Html.xhtml = true
      el.setAttrs
        test: true
      assert el.startTag() is '<div test="test">'

    it 'should not have long attributes when xhtml is false', ->
      el = Texy_Html.el 'div'
      Texy_Html.xhtml = false
      el.setAttrs
        test: true
      assert el.startTag() is '<div test>'

    it 'should return empty string if name is null', ->
      el = Texy_Html.el null
      assert el.startTag() is ''

    it 'should join array attributes', ->
      el = Texy_Html.el 'div',
        class: ['one', 'two']
      assert el.startTag() is '<div class="one two">'

    it 'should join array attributes and removes nulls', ->
      el = Texy_Html.el 'div',
        class: ['one', 'two', null]
      assert el.startTag() is '<div class="one two">'

    it 'should join styles by semicolon', ->
      el = Texy_Html.el 'div',
        style: ['color: red', 'size: 15', null]
      assert el.startTag() is '<div style="color: red;size: 15">'

    it 'should handle objects (styles)', ->
      el = Texy_Html.el 'div',
        style:
          color: 'red'
          size: 15
      assert el.startTag() is '<div style="color: red;size: 15">'

  describe '::getContentType', ->
    it "should return CONTENT_BLOCK if it is not inline element", ->
      el = Texy_Html.el('div')
      assert el.getContentType() is Texy.CONTENT_BLOCK

    it "should return CONTENT_REPLACED if it is inline element with possible content", ->
      el = Texy_Html.el('textarea')
      assert el.getContentType() is Texy.CONTENT_REPLACED

    it "should return CONTENT_MARKUP for others", ->
      el = Texy_Html.el('span')
      assert el.getContentType() is Texy.CONTENT_MARKUP

  describe '::setAttr', ->
    it 'should set attribute', ->
      el = ce 'test',
        class: 'a'
      el.setAttr 'class', 'b'
      assert _.isEqual(el.getAttrs(), {class: 'b'})

  describe '::addAttr', ->
    it 'should set attribute', ->
      el = ce 'test'
      el.addAttr 'class', 'b'
      assert _.isEqual(el.getAttrs(), {class: ['b']})

    it 'should add attr attribute', ->
      el = ce 'test',
        class: 'a'
      el.addAttr 'class', 'b'
      assert _.isEqual(el.getAttrs(), {class: ['a', 'b']})
      el = ce 'test',
        class: ['a']
      el.addAttr 'class', 'b'
      assert _.isEqual(el.getAttrs(), {class: ['a', 'b']})

