global.LOAD_PATH = if process.env.TEXY_COV then '../lib-cov' else '../lib'

global._require = (module) ->
  require "#{LOAD_PATH}/#{module}"