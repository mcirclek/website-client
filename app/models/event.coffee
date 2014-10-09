AppModel = require('models/appmodel')

class Event extends AppModel
  typeName: 'Event'
  urlRoot: '/1/events'
  idAttribute: 'eventID'

  parse: (data) ->
    data.start = moment(data.start)
    data.end = moment(data.end)
    super

  defaults: ->
    eventID: null
    name: ''
    description: ''
    start: moment()
    end: moment()
    meetingPlace: ''
    location: ''
    primaryType: null
    secondaryType: null
    status: 'open'

class EventCollection extends Backbone.Collection
  url: '/1/events'
  model: Event

class MasterEventCollection extends EventCollection
  url: '/1/events'
  model: Event

  dayMap: null
  earliest: null
  latest: null

  initialize: ->
    @on
      'add': @handleAdd
      'remove': @handleRemove
      'reset': @handleReset
    @dayMap = []

    super

  # TODO this is absolutely horrible if you are doing big jumps
  # idea: possibly keep around a list of ranges instead of trying these huge merges
  # TODO check for already in-progress sync
  ensureRange: (start, end) ->
    getStart = null
    getEnd = null

    if !@earliest || start < @earliest
      getStart = start
    if !@latest || end > @latest
      getEnd = end

    if getStart || getEnd
      getStart ?= @latest
      getEnd ?= @earliest
      if !@earliest || getStart < @earliest
        @earliest = moment(getStart)
      if !@latest || getEnd > @latest
        @latest = moment(getEnd)

      @fetch
        data:
          start: (getStart).toISOString()
          end: (getEnd).toISOString()
        remove: false
      .done()

  getMapKey: (date) ->
    return date.format('YYYY-MM-DD')

  getForDay: (date) ->
    key = @getMapKey(date)
    @dayMap[key] ?= new EventCollection()
    return @dayMap[key]

  handleAdd: (model) ->
    day = @getForDay(model.get('start'))
    day.add(model)

  handleRemove: (model) ->
    day = @getForDay(model.get('start'))
    day.remove(model)

  handleReset: ->
    @dayMap = []
    @earliest = null
    @latest = null

Event.Collection = EventCollection
Event.MasterCollection = MasterEventCollection

module.exports = Event
