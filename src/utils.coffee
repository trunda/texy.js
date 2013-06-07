# http://kevin.vanzonneveld.net
# -    depends on: urlencode
# *     example 1: http_build_query({foo: 'bar', php: 'hypertext processor', baz: 'boom', cow: 'milk'}, '', '&amp;');
# *     returns 1: 'foo=bar&amp;php=hypertext+processor&amp;baz=boom&amp;cow=milk'
# *     example 2: http_build_query({'php': 'hypertext processor', 0: 'foo', 1: 'bar', 2: 'baz', 3: 'boom', 'cow': 'milk'}, 'myvar_');
# *     returns 2: 'php=hypertext+processor&myvar_0=foo&myvar_1=bar&myvar_2=baz&myvar_3=boom&cow=milk'
module.exports['buildQuery'] = buildQuery = (formdata, numeric_prefix, arg_separator) ->

  value = []
  key   = []
  tmp   = []
  that = this

  _buildQuery = (key, val, arg_separator) ->
    _tmp = []
    val = if val is true then "1" else (if val is false then "2" else val)
    if val isnt null
      if typeof val is 'object'
        _tmp.push(_buildQuery("#{key}[#{k}]", value, arg_separator)) for k, value of val when value isnt null
        return _tmp.join arg_separator
      else if typeof val isnt 'function'
        return urlEncode(key) + "=" + urlEncode(val)
      else
        throw new Error 'There was an error processing for http_build_query().'
    return ''

  arg_separator or= "&"

  for key, value of formdata
    key = String(numeric_prefix) + key if numeric_prefix and not isNaN(key)
    query = _buildQuery key, value, arg_separator
    tmp.push query if query isnt ''

  tmp.join arg_separator

module.exports['urlEncode'] = urlEncode = (str) ->
  str = (str + '').toString();
  encodeURIComponent(str)
    .replace(/!/g, '%21')
    .replace(/'/g, '%27')
    .replace(/\(/g, '%28')
    .replace(/\)/g, '%29')
    .replace(/\*/g, '%2A')
    .replace(/%20/g, '+')