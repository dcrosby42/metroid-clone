
exports.Skree = class Skree
  constructor: ({@type
                 @motion}={}) ->
    @ctype = 'skree'
    @type ||= 'skree'
    @motion ||= 'hanging'
