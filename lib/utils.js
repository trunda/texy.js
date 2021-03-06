// Generated by CoffeeScript 1.4.0
var buildQuery, urlEncode;

module.exports['buildQuery'] = buildQuery = function(formdata, numeric_prefix, arg_separator) {
  var key, query, that, tmp, value, _buildQuery;
  value = [];
  key = [];
  tmp = [];
  that = this;
  _buildQuery = function(key, val, arg_separator) {
    var k, _tmp;
    _tmp = [];
    val = val === true ? "1" : (val === false ? "2" : val);
    if (val !== null) {
      if (typeof val === 'object') {
        for (k in val) {
          value = val[k];
          if (value !== null) {
            _tmp.push(_buildQuery("" + key + "[" + k + "]", value, arg_separator));
          }
        }
        return _tmp.join(arg_separator);
      } else if (typeof val !== 'function') {
        return urlEncode(key) + "=" + urlEncode(val);
      } else {
        throw new Error('There was an error processing for http_build_query().');
      }
    }
    return '';
  };
  arg_separator || (arg_separator = "&");
  for (key in formdata) {
    value = formdata[key];
    if (numeric_prefix && !isNaN(key)) {
      key = String(numeric_prefix) + key;
    }
    query = _buildQuery(key, value, arg_separator);
    if (query !== '') {
      tmp.push(query);
    }
  }
  return tmp.join(arg_separator);
};

module.exports['urlEncode'] = urlEncode = function(str) {
  str = (str + '').toString();
  return encodeURIComponent(str).replace(/!/g, '%21').replace(/'/g, '%27').replace(/\(/g, '%28').replace(/\)/g, '%29').replace(/\*/g, '%2A').replace(/%20/g, '+');
};
