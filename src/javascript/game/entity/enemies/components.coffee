
exports.Skree = class Skree
  constructor: ({@action
                 @direction
                 @triggerRange
                 @strafeSpeed}={}) ->
    @ctype = 'skree'
    @action ||= 'sleep' # attack | igniteFuse | explode
    @direction ||= 'neither' # left | right | neither
    @strafeSpeed ||= 50/1000
    @triggerRange ||= 32
