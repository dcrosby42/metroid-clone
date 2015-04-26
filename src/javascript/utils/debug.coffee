$ = require 'jquery'
Immutable = require 'immutable'

exports.scratch1 = (str) -> $('#scratch1').text(str)
# exports.scratch1 = (str) -> console.log str.toString()

exports.scratch2 = (str) -> $('#scratch2').text(str)
# exports.scratch2 = (str) -> console.log str.toString()

exports.scratch3 = (str) -> $('#scratch3').text(str)

exports.Immutable = Immutable
exports.imm = Immutable.fromJS

