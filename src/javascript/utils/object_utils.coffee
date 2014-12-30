_ = require 'lodash'

ObjectUtils = {}

setDeep = (obj, keyPath, value) ->
  return if !obj? or !keyPath? or keyPath.length == 0
  _setDeep obj, keyPath, value, 0, keyPath.length-1

_setDeep = (obj, keyPath, value, i, fin) ->
  key = keyPath[i]
  if i == fin
    obj[key] = value
  else
    h = obj[key]
    if !h?
      h = {}
      obj[key] = h
    _setDeep(h,keyPath,value,i+1,fin)
  obj


getDeep = (obj, keyPath) ->
  return null if !obj? or !keyPath? or keyPath.length == 0
  _getDeep obj, keyPath, 0, keyPath.length-1

_getDeep = (obj,keyPath,i,fin) ->
  key = keyPath[i]
  if i == fin
    return obj[key]
  else
    h = obj[key]
    if h?
      return _getDeep(h,keyPath,i+1,fin)
    else
      return null

getPropertiesList = (obj,keys) ->
  _.map keys, (key) -> obj[key]


ObjectUtils.setDeep = setDeep
ObjectUtils.getDeep = getDeep
ObjectUtils.getPropertiesList = getPropertiesList

module.exports = ObjectUtils

