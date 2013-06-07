module.exports = process.env.TEXY_COV
    ? require('./lib-cov')
    : require('./lib');