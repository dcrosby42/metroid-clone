ProfilerImpl = require './profiler_impl'
BufferedPusher = require '../utils/buffered_pusher'
jquery = require 'jquery'


DefaultDataEndpoint = "http://127.0.0.1:5012/capture-data"

newFlushToServer = (endpoint) -> (buffer,_) -> jquery.post endpoint, JSON.stringify(data: buffer)

flushToConsole = (buffer,_) -> console.log buffer

every60 = BufferedPusher.Conditions.length(60)

impl = null
reporter = null

module.exports =
  enable: -> impl = new ProfilerImpl()
  disable: -> impl = null

  in: (name) -> impl.in(name) if impl
  out: (name) -> impl.out(name) if impl
  count: (name) -> impl.count(name) if impl
  sample: (name,x) -> impl.sample(name,x) if impl
  debug: (name,x) -> impl.debug(name,x) if impl
  tear: (item) ->
    return null unless impl
    item = impl.tear(item)
    reporter.push item if reporter
    item
  
  useAjaxReporter: (endpoint=DefaultDataEndpoint) ->
    reporter = new BufferedPusher(newFlushToServer(endpoint), every60)
    null

  useConsoleReporter: (endpoint=null) ->
    reporter = new BufferedPusher(flushToConsole, every60)
    null

