es = require('event-stream')
river = require('river')

class RiverEventStream
  constructor: (queryString, options={}) ->
    @ctx = river.createContext()
    @query = @ctx.addQuery(queryString)
    @registered = false
    @streamName = options.streamName or 'stream'
    @includeInserts = if options.includeInserts? then !!options.includeInserts else true
    @includeRemoves = !!options.includeRemoves

  push: (data) ->
    @ctx.push(@streamName, data)

  emitTo: (stream) ->
    return if @registered
    maybeLabel = (data, label) =>
      if @includeInserts and @includeRemoves then [label, data] else data
    if @includeInserts
      @query.on 'insert', (data) -> stream.emit('data', maybeLabel(data, 'insert'))
    if @includeRemoves
      @query.on 'remove', (data) -> stream.emit('data', maybeLabel(data, 'remove'))
    @registered = true

  streamHandler: ->
    r = this
    (data) ->
      r.emitTo(this)
      r.push(data)

  throughStream: ->
    es.through(@streamHandler())



module.exports = (query, options) -> new RiverEventStream(query, options).throughStream()