# Texy.js! is human-readable text to HTML converter (http://texy.info) in
# JavaScript
#
# Copyright (c) 2004 David Grudl (http://davidgrudl.com), 2013 Jakub Truneček
#
# For the full copyright and license information, please view
# the file license.txt that was distributed with this source code.

# Dependencies
_     = require 'underscore'
utils = require '../utils'
Texy  = require '../texy'

# HTML helper.
#
# usage:
#
#     var link = 'http://texy.info',
#         anchor = TexyHtml.el('a').href(link).setText('Texy');
#     anchor.setAttrib('class', 'myclass');
#
#     alert(anchor.startTag(), anchor.endTag());

module.exports = class Texy_Html
  # Static
  @xhtml = false

  # empty elements
  @emptyElements = [
    'img', 'hr', 'br', 'input', 'meta', 'area',
    'base', 'col', 'link', 'param', 'basefont',
    'frame', 'isindex', 'wbr', 'embed'
  ]

  # see [this link](http://www.w3.org/TR/xhtml1/prohibitions.html)
  @prohibits = {
    'a': ['a','button'],
    'img': ['pre'],
    'object': ['pre'],
    'big': ['pre'],
    'small': ['pre'],
    'sub': ['pre'],
    'sup': ['pre'],
    'input': ['button'],
    'select': ['button'],
    'textarea': ['button'],
    'label': ['button', 'label'],
    'button': ['button'],
    'form': ['button', 'form'],
    'fieldset': ['button'],
    'iframe': ['button'],
    'isindex': ['button']
  }

  # elements with optional end tag in HTML
  @optionalEnds = [
    'body', 'head', 'html', 'colgroup', 'dd', 
    'dt', 'li', 'option', 'p', 'tbody', 'td',
    'tfoot', 'th', 'thead', 'tr'
  ]

  @inlineElements = {
    'ins': false,'del': false,'tt': false,'i': false,'b': false,'big': false,'small': false,
    'em': false, 'strong': false,'dfn': false,'code': false,'samp': false,'kbd': false,'var': false,'cite': false,
    'abbr': false,'acronym': false, 'sub': false,'sup': false,'q': false,'span': false,'bdo': false,'a': false,
    'object': true,'img': true,'br': true,'script': true, 'map': false,'input': true,'select': true,'textarea': true,
    'label': false,'button': true,
    'u': false,'s': false,'strike': false,'font': false,'applet': true,'basefont': false, # transitional
    'embed': true,'wbr': false,'nobr': false,'canvas': true # proprietary
  }

  constructor: ->
    @_children = []
    @attrs = {}

  # Static factory.
  #
  # * `string` element name (or NULL)
  # * `array|string` element's attributes (or textual content)
  #
  # return `TexyHtml`
  @el: (name, attrs = {}) ->
    _el = new Texy_Html()
    _el.setName(name)
    _el.setText(attrs) if typeof attrs is 'string'
    _el.setAttrs(attrs) if typeof attrs is 'object'
    _el

  # Changes element's name
  #
  # * `string`
  # * `bool`  Is element empty?
  # * return `TexyHtml`  provides a fluent interface
  # * throws `Error`
  setName: (name, empty = null) ->
    if name isnt null and typeof name isnt 'string'
      throw new Error 'Name must be string or null'
    @name = name
    @_isEmpty = if empty is null then _.contains(Texy_Html.emptyElements, name) else empty
    @

  # Returns element's name.
  #
  # * return `string`
  getName: -> @name

  # Is element empty?
  #
  # * return `boolean`
  isEmpty: -> @_isEmpty

   # Special setter for element's attribute.
   #
   # * `string` path
   # * `array` query
   # * return `TexyHtml`  provides a fluent interface
  setHref: (path, query = null) ->
    if query
      query = utils.buildQuery query, null, '&'
      path = "#{path}?#{query}" if query isnt ''

    @attrs['href'] = path
    @

  # Inserts child node.
  #
  # * `int`
  # * `TexyHtml` node
  # * `bool`
  # * return `TexyHtml`  provides a fluent interface
  # * throws `Exception`
  insert: (index, child, replace = false) ->
    if child instanceof Texy_Html or typeof child is 'string'
      if index is null
        @_children.push child
      else
        @_children.splice index, (if replace then 1 else 0), child
    else
      throw new Error 'Child node must be scalar or TexyHtml object'
    @

  # Adds new element's child.
  #
  # * `TexyHtml|string` child node
  # * return `TexyHtml`  provides a fluent interface
  add: (child) -> @insert null, child

  create: (name, attrs = []) ->
    child = Texy_Html.el name, attrs
    @add child
    child

  # Returns element's children
  #
  # * return `array`
  getChildren: -> @_children

  # Removes all children
  removeChildren: -> @_children = []

  # Set attrs
  setAttrs: (@attrs) -> @

  setText: (text) ->
    if /boolean|number|string/.test(typeof text)
      @_children = [text]
    else
      throw new Error 'Text Have to be scalar'
    @

  # Get text
  getText: ->
    result = ''
    for item in @_children
      return false if typeof item is 'object'
      result += item
    result

  endTag: ->
    return "</#{@name}>" if @name and not @isEmpty()
    ""

  startTag: ->
    return '' if @name is null
    result = "<#{@name}"

    for key, value of @attrs
      continue if value is false or value is null
      if value is true
        result += if Texy_Html.xhtml then " #{key}=\"#{key}\"" else " #{key}"
        continue
      else if _.isArray(value) or _.isObject(value)
        items = (item for item in value when item isnt null) if _.isArray(value)
        items = ("#{k}: #{v}" for k, v of value when v isnt null) if _.isObject(value) and not _.isArray(value)
        items = if key is 'style' then items.join(';') else items.join(' ')
        result += " #{key}=\"#{items}\""
        continue

      result += " #{key}=\"#{value}\""


    result + if Texy_Html.xhtml and @isEmpty() then " />" else ">"

  setAttr: (name, value) -> @attrs[name] = value; @

  getAttrs: -> @attrs

  addAttr: (name, value) ->
    @attrs[name] or= []
    @attrs[name] = [@attrs[name]] if not _.isArray(@attrs[name])
    @attrs[name].push(value)

  getContentType: ->
    return Texy.CONTENT_BLOCK if _.isUndefined(Texy_Html.inlineElements[@name])
    return if Texy_Html.inlineElements[@name] then Texy.CONTENT_REPLACED else Texy.CONTENT_MARKUP

  toString: (texy) ->
    ct = @getContentType()
    s = texy.protect @startTag(), ct
    # empty elements are finished now
    return s if @isEmpty()

    # add content
    for child in @_children
      s += if _.isObject(child) then child.toString(texy) else child

    s += texy.protect @endTag(), ct

  toHtml: (texy) -> texy.stringToHtml(@toString(texy))

  toText: (texy) -> texy.stringToText(@toString(texy))