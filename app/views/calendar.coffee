AppView = require('views/appview')

class EventDetailView extends AppView
  render: ->
    @$el.html(@template('calendar_event_detail', @model.toJSON()))
    return @

class EventView extends AppView
  className: 'event-info'

  initialize: ->
    super
    @detailView = new EventDetailView({ @model })

  events:
    'click a': 'openEvent'

  render: ->
    @$el.html(@template('calendar_event', @model.toJSON()))
    #@$el.append(@detailView.render().el)
    return @

  openEvent: ->
    $('#modal').html(@detailView.render().el).modal('show')
    return false

class DayView extends AppView
  tagName: 'li'

  initialize: ({ @date, @month }) ->
    @listenTo @model, 'add remove reset', @render
    super

  render: ->
    @$el.removeClass('out-of-range')
    if @date.month() != @month.month()
      @$el.addClass('out-of-range')

    if !@date.diff(moment(), 'days')
      @$el.addClass('today')

    @$el.html(@template('calendar_day', { @date }))
    @model.each (event) =>
      @$el.append(new EventView(model: event).render().el)

    return @

class WeekView extends AppView
  tagName: 'ul'
  className: 'week'

  initialize: ({ @weekStart, @month }) ->
    super

  render: ->
    date = moment(@weekStart)
    endDate = moment(@weekStart).add(1, 'weeks')
    @$el.empty()
    while date < endDate
      model = @model.getForDay(date)
      @$el.append(new DayView({ date: moment(date), @month, model }).render().el)
      date.add(1, 'days')

    return @

class CalendarView extends AppView
  initialize: ({ @year, @month }) ->
    super

  render: ->
    month = moment({ @year, @month, day: 1 })
    lastMonth = moment(month).subtract(1, 'months')
    nextMonth = moment(month).add(1, 'months')
    @$el.html(@template('calendar', { month, lastMonth, nextMonth }))

    weekStart = moment(month).day(0)
    while weekStart < nextMonth
      weekView = new WeekView({ @model, weekStart, month })
      @$('.calendar').append(weekView.render().el)
      weekStart.add(1, 'week')

    return @

module.exports = CalendarView
