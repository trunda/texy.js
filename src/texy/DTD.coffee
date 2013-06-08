# Texy.js! is human-readable text to HTML converter (http://texy.info) in
# JavaScript
#
# Copyright (c) 2004 David Grudl (http://davidgrudl.com), 2013 Jakub Truneček
#
# For the full copyright and license information, please view
# the file license.txt that was distributed with this source code.

strict = mode is Texy.HTML4_STRICT or mode is Texy.XHTML1_STRICT
_      = require 'underscore'
Texy   = require '../texy'

# attributes
coreattrs = {id: 1, class: 1, style: 1, title: 1, 'xml:id': 1} # extra: xml:id
i18n      = {lang: 1, dir: 1, xml:lang: 1} # extra: xml:lang
attrs     = _.extends coreattrs, i18n,
            {
              onclick: 1, ondblclick: 1, onmousedown: 1, onmouseup: 1,
              onmouseover: 1,  onmousemove: 1, onmouseout: 1, onkeypress: 1, onkeydown: 1, onkeyup: 1
            }
cellalign = _.extend attrs, {align: 1, char: 1, charoff: 1, valign: 1}

# content elements

# %block;
b = {
  ins: 1,del: 1,p: 1,h1: 1,h2: 1,h3: 1,h4: 1,
  h5: 1,h6: 1,ul: 1,ol: 1,dl: 1,pre: 1,div: 1,blockquote: 1,noscript: 1,
  noframes: 1,form: 1,hr: 1,table: 1,address: 1,fieldset: 1
}

b = _.extend b, {
  dir: 1,menu: 1,center: 1,iframe: 1,isindex: 1, # transitional
  marquee: 1 # proprietary
} if not strict

# %inline;
i = {
  'ins': 1, 'del': 1, 'tt': 1, 'i': 1, 'b': 1, 'big': 1, 'small': 1, 'em': 1, 
  'strong': 1, 'dfn': 1, 'code': 1, 'samp': 1, 'kbd': 1, 'var': 1, 'cite': 1, 'abbr': 1, 'acronym': 1, 
  'sub': 1, 'sup': 1, 'q': 1, 'span': 1, 'bdo': 1, 'a': 1, 'object': 1, 'img': 1, 'br': 1, 'script': 1, 
  'map': 1, 'input': 1, 'select': 1, 'textarea': 1, 'label': 1, 'button': 1, '%DATA': 1
}

i = _.extend i, {
  'u': 1, 's': 1, 'strike': 1, 'font': 1, 'applet': 1, 'basefont': 1,  # transitional
  'embed': 1, 'wbr': 1, 'nobr': 1, 'canvas': 1,  # proprietary
} if not strict

bi = _.extend b, i;

# Build DTD
dtd = {
  'html': [
    if strict then _.extend(i18n, {'xmlns': 1}) else _.extend(i18n, {'xmlns': 1, 'version': 1}) # extra: xmlns
    {'head': 1,'body': 1}
  ]
  'head': [
    _.extend(i18n, {'profile': 1})
    {'title': 1,'script': 1,'style': 1,'base': 1,'meta': 1,'link': 1,'object': 1,'isindex': 1}
  ]
  'title': [
    {}
    {'%DATA': 1}
  ] 
  'body': [
    _.extend(attrs, {'onload': 1, 'onunload': 1})
    if strict then _.extend({'script':  1}, b) else bi
  ] 
  'script': [
   {'charset': 1, 'type': 1, 'src': 1, 'defer': 1, 'event': 1, 'for': 1}
   {'%DATA': 1}
  ] 
  'style': [
    _.extend(i18n, {'type': 1, 'media': 1 , 'title': 1})
    {'%DATA': 1}
  ] 
  'p': [
    if strict then attrs else _.extend(attrs, {'align': 1})
    i
  ]
  'h1': [
    if strict then attrs else _.extend(attrs, {'align': 1})
    i
  ]
  'h2': [
    if strict then attrs else _.extend(attrs, {'align': 1})
    i
  ]
  'h3': [
    if strict then attrs else _.extend(attrs, {'align': 1})
    i
  ]
  'h4': [
    if strict then attrs else _.extend(attrs, {'align': 1})
    i
  ]
  'h5': [
    if strict then attrs else _.extend(attrs, {'align': 1})
    i
  ]
  'h6': [
    if strict then attrs else _.extend(attrs, {'align': 1})
    i
  ]
  'ul': [
    if strict then attrs else _.extend(attrs, {'type': 1, 'compact': 1})
    {'li': 1}
  ]
  'ol': [
    if strict then attrs else _.extend(attrs, {'type': 1, 'compact': 1, 'start': 1})
    {'li': 1}
  ]
  'li': [
    if strict then attrs else _.extend(attrs, {'type': 1, 'value': 1})
    bi
  ]
  'dl': [
    if strict then attrs else _.extend(attrs, {'compact': 1})
    {'dt': 1, 'dd': 1}
  ]
  'dt': [
    attrs
    i
  ]
  'dd': [
    attrs
    bi
  ]
  'pre': [
    if strict then attrs else _.extend(attrs, {'width': 1})
    _.omit(i, 'img', 'object', 'applet', 'big', 'small', 'sub', 'sup', 'font', 'basefont')
  ]
  'div': [
    if strict then attrs else _.extend(attrs, {'align': 1})
    bi
  ]
  'blockquote': [
    _.extend(attrs, {'cite': 1})
    if strict then _.extend({'script': 1}, b) else bi
  ]
  'noscript': [
    attrs
    bi
  ]
  'form': [
    _.extend(attrs, {'action': 1, 'method': 1, 'enctype': 1, 'accept': 1, 'name': 1, 'onsubmit': 1, 'onreset': 1, 'accept-charset': 1})
    if strict then _.extend({'script': 1}, b) else bi
  ]
  'table': [
    _.extend(attrs, {'summary': 1, 'width': 1, 'border': 1, 'frame': 1, 'rules': 1, 'cellspacing': 1, 'cellpadding': 1, 'datapagesize': 1})
    {'caption': 1, 'colgroup': 1, 'col': 1, 'thead': 1, 'tbody': 1, 'tfoot': 1, 'tr': 1}
  ]
  'caption': [
    if strict then attrs else _.extend(attrs, {'align': 1})
    i
  ]
  'colgroup': [
    _.extend(cellalign, {'span': 1, 'width': 1})
    {'col': 1}
  ]
  'thead': [
    cellalign
    {'tr': 1}
  ]
  'tbody': [
    cellalign
    {'tr': 1}
  ]
  'tfoot': [
    cellalign
    {'tr': 1}
  ]
  'tr': [
    if strict then cellalign else _.extend(cellalign, {'bgcolor': 1})
    {'td': 1, 'th': 1}
  ]
  'td': [
    _.extend(cellalign, {'abbr': 1, 'axis': 1, 'headers': 1, 'scope': 1, 'rowspan': 1, 'colspan': 1})
    bi
  ]
  'th': [
    _.extend(cellalign, {'abbr': 1, 'axis': 1, 'headers': 1, 'scope': 1, 'rowspan': 1, 'colspan': 1})
    bi
  ]
  'address': [
    attrs
    if strict then i else _.extend({'p': 1}, i)
  ]
  'fieldset': [
    attrs
    _.extend({'legend': 1}, bi)
  ]
  'legend': [
    if strict then _.extend(attrs, {'accesskey': 1}) else _.extend(attrs, {'accesskey': 1, 'align': 1})
    i
  ]
  'tt': [
    attrs
    i
  ]
  'i': [
    attrs
    i
  ]
  'b': [
    attrs
    i
  ]
  'big': [
    attrs
    i
  ]
  'small': [
    attrs
    i
  ]
  'em': [
    attrs
    i
  ]
  'strong': [
    attrs
    i
  ]
  'dfn': [
    attrs
    i
  ]
  'code': [
    attrs
    i
  ]
  'samp': [
    attrs
    i
  ]
  'kbd': [
    attrs
    i
  ]
  'var': [
    attrs
    i
  ]
  'cite': [
    attrs
    i
  ]
  'abbr': [
    attrs
    i
  ]
  'acronym': [
    attrs
    i
  ]
  'sub': [
    attrs
    i
  ]
  'sup': [
    attrs
    i
  ]
  'q': [
    _.extend(attrs, {'cite': 1})
    i
  ]
  'span': [
    attrs
    i
  ]
  'bdo': [
    _.extend(coreattrs, {'lang': 1, 'dir': 1})
    i
  ]
  'a': [
    _.extend(attrs, {'charset': 1, 'type': 1, 'name': 1, 'href': 1, 'hreflang': 1, 'rel': 1, 'rev': 1, 'accesskey': 1, 'shape': 1, 'coords': 1, 'tabindex': 1, 'onfocus': 1, 'onblur': 1})
    i
  ]
  'object': [
    _.extend(attrs, {'declare': 1, 'classid': 1, 'codebase': 1, 'data': 1, 'type': 1, 'codetype': 1, 'archive': 1, 'standby': 1, 'height': 1, 'width': 1, 'usemap': 1, 'name': 1, 'tabindex': 1})
    {'param': 1} + bi
  ]
  'map': [
    _.extend(attrs, {'name': 1})
    {'area': 1} + b
  ]
  'select': [
    _.extend(attrs, {'name': 1, 'size': 1, 'multiple': 1, 'disabled': 1, 'tabindex': 1, 'onfocus': 1, 'onblur': 1, 'onchange': 1})
    {'option': 1, 'optgroup': 1}
  ]
  'optgroup': [
    _.extend(attrs, {'disabled': 1, 'label': 1})
    {'option': 1}
  ]
  'option': [
    _.extend(attrs, {'selected': 1, 'disabled': 1, 'label': 1, 'value': 1})
    {'%DATA': 1}
  ]
  'textarea': [
    _.extend(attrs, {'name': 1, 'rows': 1, 'cols': 1, 'disabled': 1, 'readonly': 1, 'tabindex': 1, 'accesskey': 1, 'onfocus': 1, 'onblur': 1, 'onselect': 1, 'onchange': 1})
    {'%DATA': 1}
  ]
  'label': [
    _.extend(attrs, {'for': 1, 'accesskey': 1, 'onfocus': 1, 'onblur': 1})
    i # - label by TexyHtml::prohibits
  ]
  'button': [
    _.extend(attrs, {'name': 1, 'value': 1, 'type': 1, 'disabled': 1, 'tabindex': 1, 'accesskey': 1, 'onfocus': 1, 'onblur': 1})
    bi # - a input select textarea label button form fieldset, by TexyHtml::prohibits
  ]
  'ins': [
    _.extend(attrs, {'cite': 1, 'datetime': 1})
    0 # special case
  ]
  'del': [
    _.extend(attrs, {'cite': 1, 'datetime': 1})
    0 # special case
  ]
  
  # empty elements
  'img': [
    _.extend(attrs, {'src': 1, 'alt': 1, 'longdesc': 1, 'name': 1, 'height': 1, 'width': 1, 'usemap': 1, 'ismap': 1})
    false
  ]
  'hr': [
    if strict then attrs else _.extend(attrs, {'align': 1, 'noshade': 1, 'size': 1, 'width': 1})
    false
  ]
  'br': [
    if strict then coreattrs else _.extend(coreattrs, {'clear': 1})
    false
  ]
  'input': [
    _.extend(attrs, {'type': 1, 'name': 1, 'value': 1, 'checked': 1, 'disabled': 1, 'readonly': 1, 'size': 1, 'maxlength': 1, 'src': 1, 'alt': 1, 'usemap': 1, 'ismap': 1, 'tabindex': 1, 'accesskey': 1, 'onfocus': 1, 'onblur': 1, 'onselect': 1, 'onchange': 1, 'accept': 1})
    false
  ]
  'meta': [
    _.extend(i18n, {'http-equiv': 1, 'name': 1, 'content': 1, 'scheme': 1})
    false
  ]
  'area': [
    _.extend(attrs, {'shape': 1, 'coords': 1, 'href': 1, 'nohref': 1, 'alt': 1, 'tabindex': 1, 'accesskey': 1, 'onfocus': 1, 'onblur': 1})
    false
  ]
  'base': [
    if strict then {'href': 1} else {'href': 1, 'target': 1}
    false
  ]
  'col': [
    _.extend(cellalign, {'span': 1, 'width': 1})
    false
  ]
  'link': [
    _.extend(attrs, {'charset': 1, 'href': 1, 'hreflang': 1, 'type': 1, 'rel': 1, 'rev': 1, 'media': 1})
    false
  ]
  'param': [
    {'id': 1, 'name': 1, 'value': 1, 'valuetype': 1, 'type': 1}
    false
  ]
  
  # special "base content"
  '%BASE': [
    null,
    _.extend({'html': 1, 'head': 1, 'body': 1, 'script': 1}, bi)
  ]
}

# Loose DTD
if not strict
  dtd = _.extend dtd, {
    # transitional
    'dir': [
      _.extend(attrs, {'compact': 1})
      {'li': 1}
    ]
    'menu': [
      _.extend(attrs, {'compact': 1})
      {'li': 1} # it's inline-li, ignored
    ]
    'center': [
      attrs
      bi
    ]
    'iframe': [
      _.extend(coreattrs, {'longdesc': 1,'name': 1,'src': 1,'frameborder': 1,'marginwidth': 1,'marginheight': 1,'scrolling': 1,'align': 1,'height': 1,'width': 1})
      bi
    ]
    'noframes': [
      attrs
      bi
    ]
    'u': [
      attrs
      i
    ]
    's': [
      attrs
      i
    ]
    'strike': [
      attrs
      i
    ]
    'font': [
      _.extend(coreattrs, i18n, {'size': 1,'color': 1,'face': 1})
      i
    ]
    'applet': [
      _.extend(coreattrs, {'codebase': 1,'archive': 1,'code': 1,'object': 1,'alt': 1,'name': 1,'width': 1,'height': 1,'align': 1,'hspace': 1,'vspace': 1})
      _.extend({'param': 1}, bi)
    ]
    'basefont': [
      {'id': 1,'size': 1,'color': 1,'face': 1}
      false
    ]
    'isindex': [
      _.extend(coreattrs, i18n, {'prompt': 1})
      false
    ]
    
    # proprietary
    'marquee': [
      Texy.ALL
      bi
    ]
    'nobr': [
      {}
      i
    ]
    'canvas': [
      Texy.ALL
      i
    ]
    'embed': [
      Texy.ALL
      false
    ]
    'wbr': [
      {}
      false
    ]
  }

module.exports = dtd